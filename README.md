# terraform-aws-eks-external-secrets

[![Lint Status](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-eks-external-secrets)](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/blob/master/LICENSE)

Terraform module for deploying [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets), this enables to use AWS Secrets Manager and SSM Parameters inside a pre-existing EKS cluster.

## Usage

```
module "external_secrets" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-external-secrets.git"

  enabled = true

  cluster_name                     = module.eks_cluster.cluster_id
  cluster_identity_oidc_issuer     = module.eks_cluster.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks_cluster.oidc_provider_arn
  secrets_aws_region               = data.aws_region.current.name
}
```

## System architecture

![architecture](./images/architecture.png)

1. `ExternalSecrets` are added in the cluster (e.g., `kubectl apply -f external-secret-example.yml`)
2. Controller fetches `ExternalSecrets` using the Kubernetes API
3. Controller uses `ExternalSecrets` to fetch secret data from external providers (e.g, AWS Secrets Manager)
4. Controller upserts `Secrets`
5. `Pods` can access `Secrets` normally

## Add a secret

Add your secret data to your backend. For example, AWS Secrets Manager:

```
aws secretsmanager create-secret --name hello-service/password --secret-string "1234"
```

AWS Parameter Store:

```
aws ssm put-parameter --name "/hello-service/password" --type "String" --value "1234"
```

and then create a `hello-service-external-secret.yml` file:

```yml
apiVersion: "kubernetes-client.io/v1"
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: secretsManager
  # optional: specify role to assume when retrieving the data
  roleArn: arn:aws:iam::123456789012:role/test-role
  data:
    - key: hello-service/password
      name: password
  # optional: specify a template with any additional markup you would like added to the downstream Secret resource.
  # This template will be deep merged without mutating any existing fields. For example: you cannot override metadata.name.
  template:
    metadata:
      annotations:
        cat: cheese
      labels:
        dog: farfel
```

or

```yml
apiVersion: "kubernetes-client.io/v1"
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: systemManager
  data:
    - key: /hello-service/password
      name: password
```

The following IAM policy allows a user or role to access parameters matching `prod-*`.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:us-west-2:123456789012:parameter/prod-*"
    }
  ]
}
```

The IAM policy for Secrets Manager is similar ([see docs](https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html)):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-west-2:111122223333:secret:aes128-1a2b3c",
        "arn:aws:secretsmanager:us-west-2:111122223333:secret:aes192-4D5e6F",
        "arn:aws:secretsmanager:us-west-2:111122223333:secret:aes256-7g8H9i"
      ]
    }
  ]
}
```

Save the file and run:

```sh
kubectl apply -f hello-service-external-secret.yml
```

Wait a few minutes and verify that the associated `Secret` has been created:

```sh
kubectl get secret hello-service -o=yaml
```

The `Secret` created by the controller should look like:

```yml
apiVersion: v1
kind: Secret
metadata:
  name: hello-service
  annotations:
    cat: cheese
  labels:
    dog: farfel
type: Opaque
data:
  password: MTIzNA==
```

### Create secrets of other types than opaque

You can override `ExternalSecret` type using `template`, for example:

```yaml
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: hello-docker
spec:
  backendType: systemManager
  template:
    type: kubernetes.io/dockerconfigjson
  data:
    - key: /hello-service/hello-docker
      name: .dockerconfigjson
```


## Backends

kubernetes-external-secrets supports AWS Secrets Manager, AWS System Manager, Hashicorp Vault, Azure Key Vault, Google Secret Manager and Alibaba Cloud KMS Secret Manager.

### AWS Secrets Manager

kubernetes-external-secrets supports both JSON objects ("Secret
key/value" in the AWS console) or strings ("Plaintext" in the AWS
console). Using JSON objects is useful when you need to atomically
update multiple values. For example, when rotating a client
certificate and private key.

When writing an ExternalSecret for a JSON object you must specify the
properties to use. For example, if we add our hello-service
credentials as a single JSON object:

```
aws secretsmanager create-secret --region us-west-2 --name hello-service/credentials --secret-string '{"username":"admin","password":"1234"}'
```

We can declare which properties we want from `hello-service/credentials`:

```yml
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: secretsManager
  # optional: specify role to assume when retrieving the data
  roleArn: arn:aws:iam::123456789012:role/test-role
  # optional: specify region
  region: us-east-1
  data:
    - key: hello-service/credentials
      name: password
      property: password
    - key: hello-service/credentials
      name: username
      property: username
    - key: hello-service/credentials
      name: password_previous
      # Version Stage in Secrets Manager
      versionStage: AWSPREVIOUS
      property: password
    - key: hello-service/credentials
      name: password_versioned
      # Version ID in Secrets Manager
      versionId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      property: password
```

alternatively you can use `dataFrom` and get all the values from `hello-service/credentials`:

```yml
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: secretsManager
  # optional: specify role to assume when retrieving the data
  roleArn: arn:aws:iam::123456789012:role/test-role
  # optional: specify region
  region: us-east-1
  dataFrom:
    - hello-service/credentials
```

`data` and `dataFrom` can of course be combined, any naming conflicts will use the last defined, with `data` overriding `dataFrom`:

```yml
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: secretsManager
  # optional: specify role to assume when retrieving the data
  roleArn: arn:aws:iam::123456789012:role/test-role
  # optional: specify region
  region: us-east-1
  dataFrom:
    - hello-service/credentials
  data:
    - key: hello-service/migration-credentials
      name: password
      property: password
```

### AWS SSM Parameter Store

You can scrape values from SSM Parameter Store individually or by providing a path to fetch all keys inside.

Additionally you can also scrape all sub paths (child paths) if you need to. The default is not to scrape child paths.

```yml
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: hello-service
spec:
  backendType: systemManager
  # optional: specify role to assume when retrieving the data
  roleArn: arn:aws:iam::123456789012:role/test-role
  # optional: specify region
  region: us-east-1
  data:
    - key: /foo/name
      name: fooName
    - path: /extra-people/
      recursive: false
```

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.13, < 4.0 |
| helm | >= 1.0, < 3.0 |
| kubernetes | >= 1.10.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.13, < 4.0 |
| helm | >= 1.0, < 3.0 |
| kubernetes | >= 1.10.0, < 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_identity\_oidc\_issuer | The OIDC Identity issuer for the cluster. | `string` | n/a | yes |
| cluster\_identity\_oidc\_issuer\_arn | The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account. | `string` | n/a | yes |
| cluster\_name | The name of the cluster | `string` | n/a | yes |
| create\_namespace | Whether to create k8s namespace with name defined by `namespace` | `bool` | `true` | no |
| enabled | n/a | `bool` | `true` | no |
| helm\_chart\_name | External Secrets chart name. | `string` | `"kubernetes-external-secrets"` | no |
| helm\_chart\_release\_name | External Secrets release name. | `string` | `"kubernetes-external-secrets"` | no |
| helm\_chart\_repo | External Secrets repository name. | `string` | `"https://external-secrets.github.io/kubernetes-external-secrets/"` | no |
| helm\_chart\_version | External Secrets chart version. | `string` | `"7.2.1"` | no |
| mod\_dependency | Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable | `any` | `null` | no |
| namespace | Kubernetes namespace to deploy EKS Spot termination handler Helm chart. | `string` | `"kube-external-secrets"` | no |
| secrets\_aws\_region | AWS region where secrets are stored. | `string` | n/a | yes |
| service\_account\_name | External Secrets service account name | `string` | `"external-secrets"` | no |
| settings | Additional settings which will be passed to the Helm chart values, see https://github.com/external-secrets/kubernetes-external-secrets/tree/master/charts/kubernetes-external-secrets | `map(any)` | `{}` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/blob/master/LICENSE) for full details.

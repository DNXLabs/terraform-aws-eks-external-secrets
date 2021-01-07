# terraform-aws-eks-external-secrets

[![Lint Status](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-eks-external-secrets)](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.13, < 4.0 |
| helm | >= 1.0, < 1.4.0 |
| kubernetes | >= 1.10.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.13, < 4.0 |
| helm | >= 1.0, < 1.4.0 |
| kubernetes | >= 1.10.0 |

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
| helm\_chart\_version | External Secrets chart version. | `string` | `"6.1.0"` | no |
| mod\_dependency | Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable | `any` | `null` | no |
| namespace | Kubernetes namespace to deploy EKS Spot termination handler Helm chart. | `string` | `"kube-external-secrets"` | no |
| secrets\_aws\_region | AWS region where secrets are stored. | `string` | n/a | yes |
| service\_account\_name | External Secrets service account name | `string` | `"external-secrets"` | no |
| settings | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard | `map(any)` | `{}` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-eks-external-secrets/blob/master/LICENSE) for full details.
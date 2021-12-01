variable "enabled" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "secrets_aws_region" {
  type        = string
  description = "AWS region where secrets are stored."
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Application log level"
}

variable "cluster_identity_oidc_issuer" {
  type        = string
  description = "The OIDC Identity issuer for the cluster."
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
}

variable "helm_chart_name" {
  type        = string
  default     = "kubernetes-external-secrets"
  description = "External Secrets chart name."
}

variable "helm_chart_release_name" {
  type        = string
  default     = "kubernetes-external-secrets"
  description = "External Secrets release name."
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://external-secrets.github.io/kubernetes-external-secrets/"
  description = "External Secrets repository name."
}

variable "helm_chart_version" {
  type        = string
  default     = "7.2.1"
  description = "External Secrets chart version."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `namespace`"
}

variable "namespace" {
  type        = string
  default     = "kube-external-secrets"
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}

variable "service_account_name" {
  type        = string
  default     = "external-secrets"
  description = "External Secrets service account name"
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable"
}

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://github.com/external-secrets/kubernetes-external-secrets/tree/master/charts/kubernetes-external-secrets"
}
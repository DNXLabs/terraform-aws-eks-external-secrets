resource "helm_release" "kubernetes_external_secrets" {
  depends_on = [var.mod_dependency, kubernetes_namespace.kubernetes_external_secrets]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "env.AWS_REGION"
    value = var.secrets_aws_region
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kubernetes_external_secrets[0].arn
  }

  set {
    name  = "securityContext.fsGroup"
    value = 65534
  }

  set {
    name  = "customResourceManagerDisabled"
    value = true
  }

  values = [
    yamlencode(var.settings)
  ]

}
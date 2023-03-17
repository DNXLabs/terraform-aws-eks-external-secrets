resource "helm_release" "external_secrets" {
  depends_on = [var.mod_dependency, kubernetes_namespace.external_secrets]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = kubernetes_namespace.external_secrets[0].id

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets[0].arn
  }

  values = [
    yamlencode(var.settings)
  ]

}

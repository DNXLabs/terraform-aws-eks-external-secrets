resource "kubernetes_namespace" "external_secrets" {
  depends_on = [var.mod_dependency]
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0
  metadata {
    name = var.namespace
  }
}


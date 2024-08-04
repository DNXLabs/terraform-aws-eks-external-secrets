output "iam_role_arn" {
  value = aws_iam_role.external_secrets[0].arn
}

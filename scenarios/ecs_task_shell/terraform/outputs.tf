output "cloudgoat_output_aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "cloudgoat_output_cacique_access_key_id" {
  value     = aws_iam_access_key.cacique.id
  sensitive = true
}

output "cloudgoat_output_cacique_secret_key" {
  value     = aws_iam_access_key.cacique.secret
  sensitive = true
}
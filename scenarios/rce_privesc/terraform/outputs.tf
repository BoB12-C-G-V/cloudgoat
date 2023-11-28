#IAM User Credentials
output "cloudgoat_output_bob_access_key_id" {
  value = aws_iam_access_key.cg-startuser.id
}

output "cloudgoat_output_bob_secret_key" {
  value     = aws_iam_access_key.cg-startuser.secret
  sensitive = true
}
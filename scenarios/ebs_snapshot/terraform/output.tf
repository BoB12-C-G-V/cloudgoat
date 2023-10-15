#IAM User Credentials
output "cloudgoat_output_block_access_key_id" {
  value = aws_iam_access_key.cg-block.id
}
output "cloudgoat_output_block_secret_key" {
  value     = aws_iam_access_key.cg-block.secret
  sensitive = true
}



output "output_playerA_access_key_id" {
  value = aws_iam_access_key.playerA_access_key.id
}
output "output_playerA_secret_key" {
  value     = aws_iam_access_key.playerA_access_key.secret
  sensitive = true
}


output "output_playerB_access_key_id" {
  value = aws_iam_access_key.playerB_access_key.id
}
output "output_playerB_secret_key" {
  value     = aws_iam_access_key.playerB_access_key.secret
  sensitive = true
}
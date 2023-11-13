
output "output_player_access_key_id" {
  value = aws_iam_access_key.player_access_key.id
}
output "output_player_secret_key" {
  value     = aws_iam_access_key.player_access_key.secret
  sensitive = true
}
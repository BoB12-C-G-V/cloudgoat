output "player_access_key" {
  value = aws_iam_access_key.player_access_key.id
}

output "player_secret_key" {
  value = aws_iam_access_key.player_access_key.secret
  sensitive = true
}


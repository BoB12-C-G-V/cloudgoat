
#Required: Always output the AWS Account ID
output "cloudgoat_output_aws_account_id" {
  value = "${data.aws_caller_identity.aws-account-id.account_id}"
}
output "cloudgoat_output_target_ec2_server_ip" {
  value = "${aws_instance.ec2-vulnerable-proxy-server.public_ip}"
}

#IAM User Credentials
output "cloudgoat_output_bob_access_key_id" {
  value = aws_iam_access_key.cg-startuser.id
}
output "cloudgoat_output_bob_secret_key" {
  value     = aws_iam_access_key.cg-startuser.secret
  sensitive = true
}

output "cloudgoat_output_username" {
  value = aws_iam_user.cg-startuser.name
}

#주석
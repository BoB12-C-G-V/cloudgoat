resource "null_resource" "cg-create-scgmod-credentials-file" {
  provisioner "local-exec" {
      command = "touch ../assets/scgmod_accessKeys.txt && echo ${aws_iam_access_key.cg-scgmod.id} >>../assets/scgmod_accessKeys.txt && echo ${aws_iam_access_key.cg-scgmod.secret} >>../assets/scgmod_accessKeys.txt"
  }
}
resource "null_resource" "cg-create-scgmod-credentials-file" {
  provisioner "local-exec" {
      command = "touch ../assets/scgmod-accessKeys.txt && echo ${aws_iam_access_key.cg-scgmod.id} >>../assets/scgmod-accessKeys.txt && echo ${aws_iam_access_key.cg-scgmod.secret} >>../assets/scgmod-accessKeys.txt"
  }
}
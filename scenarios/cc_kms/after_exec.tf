resource "null_resource" "execute_script" {
  provisioner "local-exec" {
    command = <<-EOT

      git config --global credential.helper '!aws codecommit credential-helper $@'
      git config --global credential.UseHttpPath true


      git clone ${aws_codecommit_repository.myrepo.clone_url_http}
      cd ${aws_codecommit_repository.myrepo.repository_name}

      
      touch test.txt
      git add .
      git commit -m "Commit AKIA4O2ICJQAQHSHMGPM"
      

      git push origin master

      cd ..
      rm -rf ${aws_codecommit_repository.myrepo.repository_name}
    EOT
  }

  depends_on = [aws_codecommit_repository.myrepo]
}

output "http_url" {
  value = aws_codecommit_repository.myrepo.clone_url_http
  depends_on = [null_resource.execute_script]
}

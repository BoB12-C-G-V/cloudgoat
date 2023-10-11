resource "aws_codecommit_repository" "myrepo" {
  repository_name = "CC-Repo"
  description     = "This is the Sample App Repository"
  default_branch  = "master"
}




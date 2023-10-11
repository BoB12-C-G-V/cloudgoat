resource "aws_ecs_cluster" "cluster" {
  name = "cg-cluster-${var.cgid}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
# EBS 볼륨 생성
resource "aws_ebs_volume" "example_ebs_volume" {
  availability_zone = "us-east-1"
  size              = 1 # 볼륨 크기 (GB)
  tags = {
    Name        = "Hello IAM"
    description = "There is no secret-string never"
  }
  type = "gp2" # 볼륨 유형

  #public ebs
  encrypted = false
}




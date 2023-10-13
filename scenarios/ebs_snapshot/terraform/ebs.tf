# EBS 볼륨 생성
resource "aws_ebs_volume" "example_ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 1 # 볼륨 크기 (GB)
  tags = {
    Name        = "Hello IAM"
    description = "There is no secret-string never"
  }
  type = "gp2" # 볼륨 유형

  #public ebs
  encrypted = false
}


# EBS 스냅샷 생성
resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_ebs_volume.example_ebs_volume.id
  tags = {
    Name = "Hello IAM?"
  }

  depends_on = [aws_instance.my_instance]
}

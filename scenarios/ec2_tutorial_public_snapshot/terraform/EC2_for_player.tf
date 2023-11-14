


resource "aws_instance" "Target_EC2" {
  ami                         = var.ami # 사용할 AMI ID를 지정하세요.
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Couque_Dasse_sg.id]

  key_name = aws_key_pair.bob_key_pair.key_name

  # password 접속 활성화
  user_data = <<-EOF
    #!/bin/bash
    sudo mkdir /mnt/mydata
    EOF

  tags = {
    Name     = "BoB12thCGV-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}


#SSH Key Pair 생성
resource "aws_key_pair" "bob_key_pair" {
  key_name = "bob_key_pair" # SSH 키 이름
  public_key = file("${var.ssh-public-key-for-ec2}") # 공개 키 파일의 경로를 지정하세요.
  # public_key = file("~/.ssh/id_rsa.pub") # 공개 키 파일의 경로를 지정하세요.
}
resource "aws_instance" "my_instance" {
  ami               = var.ami # 사용할 AMI ID를 지정하세요.
  instance_type     = var.instance_type
  availability_zone = "us-east-1a"

  #EBS볼륨을 마운트 후 프로비저닝 실시
  depends_on = [aws_ebs_volume.example_ebs_volume]

  # 보안 그룹을 연결.
  vpc_security_group_ids = [aws_security_group.Couque_Dasse_sg.id]

  # IAM 역할 연결
  iam_instance_profile = aws_iam_instance_profile.ec2_access_profile.name

  # SSH 키 연결
  key_name = aws_key_pair.bob_key_pair.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Wait for the EBS volume to be available
    while [ ! -e /dev/sdb ]; do sleep 1; done

    # Create a filesystem on the EBS volume
    mkfs -t ext4 /dev/sdb

    # Mount the EBS volume
    mkdir /mnt/mydata
    mount /dev/sdb /mnt/mydata

    # Add an entry to /etc/fstab for persistent mounting
    echo '/dev/sdb /mnt/mydata ext4 defaults 0 0' >> /etc/fstab

    echo "Hello IAM" > /mnt/mydata/hello.txt
    EOF
}


#SSH Key Pair 생성
resource "aws_key_pair" "bob_key_pair" {
  key_name   = "bob_key_pair"            # SSH 키 이름
  public_key = file("~/.ssh/id_rsa.pub") # 공개 키 파일의 경로를 지정하세요.
}

#EBS연결
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.example_ebs_volume.id
  instance_id = aws_instance.my_instance.id
}

# EBS 스냅샷 생성
resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_ebs_volume.example_ebs_volume.id
  tags = {
    Name = "Hello IAM?"
  }

  depends_on = [aws_instance.my_instance, aws_volume_attachment.ebs_att,aws_instance.ec2FORfree]
}
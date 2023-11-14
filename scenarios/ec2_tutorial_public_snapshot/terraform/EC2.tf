resource "aws_instance" "my_instance" {
  ami               = var.ami # 사용할 AMI ID를 지정하세요.
  instance_type     = "t2.micro"

  #EBS볼륨을 마운트 후 프로비저닝 실시
  depends_on = [aws_ebs_volume.example_ebs_volume]

  # 보안 그룹을 연결.
  vpc_security_group_ids = [aws_security_group.Couque_Dasse_sg.id]

  # IAM 역할 연결
  iam_instance_profile = aws_iam_instance_profile.ec2_access_profile.name

  # SSH 키 연결
  # key_name = aws_key_pair.bob_key_pair.key_name

  user_data = <<-EOF
    #!/bin/bash
    while [ ! -e /dev/sdb ]; do sleep 1; done

    mkfs -t ext4 /dev/sdb

    mkdir /mnt/mydata
    mount /dev/sdb /mnt/mydata

    echo '/dev/sdb /mnt/mydata ext4 defaults 0 0' >> /etc/fstab

    echo "cg-secret-string" > /mnt/mydata/secret_string.txt
    EOF

  tags = {
    Name     = "cg-public_EBS_Snapshot_With_EBS-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}




#EBS연결
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.example_ebs_volume.id
  instance_id = aws_instance.my_instance.id
  depends_on  = [aws_instance.my_instance]
}

# EBS 스냅샷 생성
resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_ebs_volume.example_ebs_volume.id
  tags = {
    Name = "Hello IAM?"
  }

  depends_on = [aws_instance.Target_EC2]
}
#IAM Role
resource "aws_iam_role" "aws_ssm_role" {
  name = "aws_ssm_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "RCE-Privesc-Role-policy-attachment-s3" {
  role = "${aws_iam_role.aws_ssm_role.name}"
  policy_arn = "${data.aws_iam_policy.aws-admin-access.arn}"
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile-${var.cgid}"
  role = "${aws_iam_role.aws_ssm_role.name}"
}

#Security Groups
resource "aws_security_group" "cg-ec2-security-group" {
  name = "cg-ec2-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance"
  vpc_id = "${aws_vpc.cg-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
   from_port =80
   to_port =80
   protocol	="tcp"
	cidr_blocks=["127.0.0.1/32"]
 }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
     Name = "cg-ec2-ssh-${var.cgid}"
     Stack = "${var.stack-name}"
     Scenario = "${var.scenario-name}"
   }
}

#AWS Key Pair
resource "aws_key_pair" "cg-ec2-key-pair" {
  key_name = "cg-ec2-key-pair-${var.cgid}"
  public_key = "${file(var.ssh-public-key-for-ec2)}"
}

#EC2 Instance
resource "aws_instance" "ec2-vulnerable-proxy-server" {
    ami = "ami-0a313d6098716f372"
    instance_type = "t2.micro"
    iam_instance_profile = "${aws_iam_instance_profile.cg-ec2-instance-profile.name}"
    subnet_id = "${aws_subnet.cg-public-subnet-1.id}"
    associate_public_ip_address = true
    vpc_security_group_ids = [
        "${aws_security_group.cg-ec2-security-group.id}",
    ]
    key_name = "${aws_key_pair.cg-ec2-key-pair.key_name}"
    root_block_device {
        volume_type = "gp2"
        volume_size = 8
        delete_on_termination = true
    }
    provisioner "file" {
        source = "../assets/index.php"
        destination = "/home/ubuntu/index.php"
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = "${file(var.ssh-private-key-for-ec2)}"
          host = self.public_ip
        }
      }
    user_data = <<-EOF
    #!/bin/bash

    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install apache2 php libapache2-mod-php -y
    sudo mv /home/ubuntu/index.php /var/www/html/
    sudo rm -rf /var/www/html/index.html
    systemctl start apache2.service systemctl enable apache-service.service
  EOF

    tags = {
        Name = "RCE_Privesc_web"
        Description = "Web Application"
    }
}
#IAM Role
resource "aws_iam_role" "RCE-Privesc-Role" {
  name = "RCE-Privesc-Role-${var.cgid}"
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
  role = "${aws_iam_role.RCE-Privesc-Role.name}"
  policy_arn = "${data.aws_iam_policy.s3-full-access.arn}"
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile-${var.cgid}"
  role = "${aws_iam_role.RCE-Privesc-Role.name}"
}

#Security Groups
resource "aws_security_group" "cg-ec2-ssh-security-group" {
  name = "cg-ec2-ssh-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over SSH"
  vpc_id = "${aws_vpc.cg-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "cg-ec2-http-security-group" {
 name ="cg-ec2-http-${var.cgid}"
 description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over HTTP"
 vpc_id ="${aws_vpc.cg-vpc.id}"

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
      cidr_blocks = [
          "0.0.0.0/0"
      ]
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
        "${aws_security_group.cg-ec2-ssh-security-group.id}",
        "${aws_security_group.cg-ec2-http-security-group.id}"
    ]
    key_name = "${aws_key_pair.cg-ec2-key-pair.key_name}"
    root_block_device {
        volume_type = "gp2"
        volume_size = 8
        delete_on_termination = true
    }
    user_data = <<-EOF
    #!/bin/bash

    echo '<?php' > /var/www/html/index.php
    echo 'if(isset($_GET["cmd"])) {' >> /var/www/html/index.php
    echo 'system($_GET["cmd"]);' >> /var/www/html/index.php
    echo '}' >> /var/www/html/index.php
    echo '?>' >> /var/www/html/index.php

    systemctl restart apache2.service
  EOF
    tags = {
        Name = "RCE_Privesc_web"
        Description = "Web Application"
    }
}
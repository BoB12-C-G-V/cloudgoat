resource "aws_instance" "ec2FORfree" {
  ami                         = var.ami # 사용할 AMI ID를 지정하세요.
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile_for_SSM.name
  associate_public_ip_address = true
  depends_on                  = [aws_instance.my_instance]
  vpc_security_group_ids      = [aws_security_group.Couque_Dasse_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    EOF

  tags = {
    Name     = "cg-public_EBS_Snapshot_With_SSM-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "ssm_role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssmNec2_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_instance_profile_for_SSM" {
  name = "awsIAMInstanceProfileForSSM"
  role = aws_iam_role.ssm_role.name
}
#=========starting IAM================

resource "aws_iam_user" "cg-block" {
  name = "block"
  tags = {
    Name     = "cg-block-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "cg-block" {
  user = aws_iam_user.cg-block.name
}

resource "aws_iam_policy" "ec2_creator" {
  name = "EC2CreatorPolicy"

  description = "IAM policy for EC2 instance creation"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:AttachVolume",
          "ec2:Describe*",
          "ssm:SendCommand",
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssm:StartSession",
          "ssm:DescribeInstanceInformation"
        ],
        Resource = "*"
      }
    ]
  })
}

# ec2_access_role 정책 연결
resource "aws_iam_user_policy_attachment" "ec2_poclicy_attachment" {
  user       = aws_iam_user.cg-block.name
  policy_arn = aws_iam_policy.ec2_creator.arn
}



#==========End IAM ===================





#==========Admin IAM =================

resource "aws_iam_user" "cg-music" {
  name = "music"
  tags = {
    Name     = "cg-music-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "cg-music" {
  user = aws_iam_user.cg-music.name
}


resource "aws_iam_policy" "AdministratorAccess" {
  name        = "AdministratorAccess"
  description = "AdministratorAccess"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_user_policy_attachment" "AdministratorAccessAttachment" {
  user       = aws_iam_user.cg-music.name
  policy_arn = aws_iam_policy.AdministratorAccess.arn
}

#==========End Admin IAM =============



#==========EC2 IAM Role ==============
#EC2 IAM role
resource "aws_iam_role" "ec2_access_role" {
  name = "ec2_access_role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_instance_profile" "ec2_access_profile" {
  name = "awsIamEc2AccessProfile"
  role = aws_iam_role.ec2_access_role.name
}


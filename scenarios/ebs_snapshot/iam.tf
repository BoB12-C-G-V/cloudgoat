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
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:AttachVolume",
          "ec2:Describe*",
          "ec2:RegisterImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# ec2_access_role 정책 연결
# ec2생성 및 접근이 가능해짐
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  policy_arn = aws_iam_policy.ec2_creator.arn
  role       = aws_iam_role.ec2_access_role.name
}

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




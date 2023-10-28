# Define IAM role for EC2 Instance.
# Assume that excessive privileges are set for this role.
resource "aws_iam_role" "ec2_role" {
  name = "cg-web-developer-role-${var.cgid}"
  tags = {
    deployment_profile = var.profile
    Stack              = var.stack-name
    Scenario           = var.scenario-name
  }


  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]

  inline_policy {
    name   = "cg-web-role-policy-${var.cgid}"
    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Sid      = "VisualEditor0",
          Effect   = "Allow",
          Resource = "*",
          Action   = [
            "iam:PassRole",
            "iam:Get*",
            "ec2:DescribeInstances",
            "iam:List*",
            "ecs:RunTask",
            "ecs:Describe*",
            "ecs:RegisterTaskDefinition",
            "ec2:DescribeSubnets",
            "ecs:List*",
            "s3:ListBucket",
          ]
        }
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role" "s3_access" {
  name = "cg-s3-access-role-${var.cgid}"
  tags = {
    deployment_profile = var.profile
    Stack              = var.stack-name
    Scenario           = var.scenario-name
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonS3FullAccess"
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
          ]
        }
      },
    ]
  })
}

# Define Lambda's role for sending mail if GuardDuty detects an attack.
# The mail will be sent with SES.
resource "aws_iam_role" "lambda_role" {
  name = "cg-lambda-role-${var.cgid}"
  tags = {
    deployment_profile = var.profile
    Stack              = var.stack-name
    Scenario           = var.scenario-name
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess",
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cg_web_developer_policy" {
  name   = "cg-web-developer-policy-${var.cgid}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "VisualEditor0",
        Effect    = "Allow",
        Resource  = "*",
        Action    = [
          "iam:PassRole",
          "iam:Get*",
          "ec2:DescribeInstances",
          "iam:List*",
          "ecs:RunTask",
          "ecs:Describe*",
          "ecs:RegisterTaskDefinition",
          "ec2:DescribeSubnets",
          "ecs:List*",
          "s3:*"
        ]
      }
    ]
  })
}

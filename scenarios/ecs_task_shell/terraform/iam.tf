resource "aws_iam_user" "cacique" {
  name = "cg-cacique-${var.cgid}"
  tags = {
    deployment_profile = var.profile
    Stack = var.stack-name
    Scenario = var.scenario-name
  }
}

resource "aws_iam_user" "trail-manager" {
  name = "cg-trail-manager-${var.cgid}"
  tags = {
    deployment_profile = var.profile
    Stack = var.stack-name
    Scenario = var.scenario-name
  }
}

resource "aws_iam_access_key" "cacique" {
  user = aws_iam_user.cacique.name
}

resource "aws_iam_user_policy_attachment" "trail-manager-policy" {
  user       = aws_iam_user.trail-manager.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrail_FullAccess"
}

resource "aws_iam_user_policy_attachment" "cacique-s3-policy" {
  user       = aws_iam_user.trail-manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy" "cacique-inline-policy" {
  user   = aws_iam_user.cacique.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:Get*",
                "iam:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": aws_iam_role.run_task.arn
        }
    ]
  })
}
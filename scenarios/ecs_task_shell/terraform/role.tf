resource "aws_iam_role" "run_task" {
  name                = "cg-run-task-${var.cgid}"
  assume_role_policy  = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service: "ecs-tasks.amazonaws.com",
          AWS: aws_iam_user.cacique.arn
        },
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.runtask_policy.arn]

}

resource "aws_iam_role" "lambda" {
  name                = "cg-lambda-role-${var.cgid}"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.lambda_ex_policy.arn]

  inline_policy {
    name   = "cg-lambda-inline-policy-${var.cgid}"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "ecs:DeregisterTaskDefinition",
          "Resource": "*"
        }
      ]
    })
  }
}

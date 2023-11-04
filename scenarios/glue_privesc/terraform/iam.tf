resource "aws_iam_user" "cg-run-app" {
  name = "cg-run-app-${var.cgid}"
  tags = {
    Name     = "cg-run-app-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

# 엑세스키 생성
resource "aws_iam_access_key" "cg-run-app_access_key" {
  user = aws_iam_user.cg-run-app.name
}


resource "aws_iam_policy_attachment" "user_RDS_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  users      = [aws_iam_user.cg-run-app.name]
}

resource "aws_iam_policy_attachment" "user_s3_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  users      = [aws_iam_user.cg-run-app.name]
}

resource "aws_iam_user" "cg-glue-admin" {
  name = "cg-glue-admin-${var.cgid}"
  tags = {
    Name     = "cg-glue-admin-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_policy" "glue_management_policy" {
  name        = "glue_management_policy"
  description = "glue_management"
  policy = jsondecode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "glue:CreateJob",
            "iam:PassRole",
            "iam:Get*",
            "iam:List*",
            "glue:CreateTrigger",
            "glue:StartJobRun",
            "glue:UpdateJob"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "VisualEditor1",
          "Effect" : "Allow",
          "Action" : "s3:ListBucket",
          "Resource" : "arn:aws:s3:::test-glue-scenario2"
        }
      ]
    }
  )

}


resource "aws_iam_user_policy_attachment" "attache_glue_management_policy" {
  user       = aws_iam_user.cg-glue-admin.name
  policy_arn = aws_iam_policy.glue_management_policy.arn
}

resource "aws_iam_access_key" "name" {
  user = aws_iam_user.cg-glue-admin.name
}


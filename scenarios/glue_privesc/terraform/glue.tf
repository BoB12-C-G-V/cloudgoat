resource "aws_iam_role" "glue_ETL_role" {
  name = "glue_ETL_role" # 역할의 이름을 지정하세요

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["glue.amazonaws.com","rds.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "glue_s3_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.glue_ETL_role.name]
}

resource "aws_iam_policy_attachment" "glue_RDS_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.glue_ETL_role.name]
}

resource "aws_iam_policy_attachment" "glue_Console_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.glue_ETL_role.name]
}

resource "aws_iam_policy_attachment" "glue_Service_role" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueServiceRole" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.glue_ETL_role.name]
}


resource "aws_iam_role" "ssm_parameter_role" {
  name = "ssm_parameter_role" # 역할의 이름을 지정하세요

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ssm_s3_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.ssm_parameter_role.name]
}

resource "aws_iam_policy_attachment" "SSM_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess" # AmazonS3FullAccess 정책 ARN
  roles      = [aws_iam_role.ssm_parameter_role.name]
}


resource "aws_iam_role" "s3_to_gluecatalog_lambda_role" {
  name = "s3_to_gluecatalog_lambda_role" # 역할의 이름을 지정하세요

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_s3_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.s3_to_gluecatalog_lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_Glue_full_access" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  roles      = [aws_iam_role.s3_to_gluecatalog_lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_Execute" {
  name       = "GlueS3FullAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.s3_to_gluecatalog_lambda_role.name]
}
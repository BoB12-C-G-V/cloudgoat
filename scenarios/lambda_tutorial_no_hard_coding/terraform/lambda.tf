data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "archive_file" "target_lambda" {
  type        = "zip"
  source_file = "lambda/tagging.py"
  output_path = "tagging.zip"
}


resource "aws_lambda_function" "add_tag" {
  filename         = "tagging.zip"
  function_name    = "tagging"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "tagging.lambda_handler"
  source_code_hash = data.archive_file.target_lambda.output_base64sha256
  runtime          = "python3.11"
}


resource "aws_lambda_permission" "s3_invoke_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_tag.arn
  principal     = "s3.amazonaws.com"
}



resource "aws_iam_policy" "s3_tagging_policy" {
  name        = "s3-tagging-policy"
  description = "IAM policy for S3 object tagging"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObjectTagging",
          "s3:GetBucketLocation",
        ],
        Resource = ["arn:aws:s3:::teamcgv-test/*"]
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "s3_tagging_attachment" {
  name       = "s3-tagging-attachment"
  policy_arn = aws_iam_policy.s3_tagging_policy.arn
  roles      = [aws_iam_role.iam_for_lambda.name]
}

resource "aws_iam_policy_attachment" "attach_lambda_basic_policy" {
  name       = "attach_lambda_basic_policy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.iam_for_lambda.name]
}
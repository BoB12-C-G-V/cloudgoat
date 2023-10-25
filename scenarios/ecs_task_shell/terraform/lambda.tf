resource "aws_lambda_function" "guardduty_lambda" {
  function_name = "cg-guardduty-lambda-${var.cgid}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = "../assets/lambda.zip"
  source_code_hash = filebase64sha256("../assets/lambda.zip")

  environment {
    variables = {
      bucket_name_var = aws_s3_bucket.secret-s3-bucket.bucket
      dst_email       = var.user_email
      src_email       = var.user_email
    }
  }
}

resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.guardduty_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_events.arn
}
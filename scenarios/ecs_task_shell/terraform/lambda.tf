resource "aws_lambda_function" "guardduty_lambda" {
  function_name = "cg-guardduty-lambda-${var.cgid}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  filename      = "../assets/lambda.zip"
}
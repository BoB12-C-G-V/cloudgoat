resource "aws_lambda_function" "ecs_event_handler" {
  function_name = "cg-ecs-event-handler-${var.cgid}"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.11"
  filename      = "../assets/lambda.zip"
}
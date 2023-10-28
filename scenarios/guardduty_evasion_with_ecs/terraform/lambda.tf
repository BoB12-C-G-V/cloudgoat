# Define Lambda for sending emails.
resource "aws_lambda_function" "guardduty_lambda" {
  function_name = "cg-guardduty-lambda-${var.cgid}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  filename      = "../assets/lambda.zip"
  depends_on    = [null_resource.lambda_zip]

  environment {
    variables = {
      USER_EMAIL            = var.user_email
      IAM_ROLE_1            = aws_iam_role.ec2_role.name
      IAM_ROLE_2            = aws_iam_role.ec2_role_sub.name
      GUARDDUTY_DETECTOR_ID = aws_guardduty_detector.detector.id
      ACCOUNT_ID            = data.aws_caller_identity.current.account_id
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

resource "null_resource" "lambda_zip" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
      if [ -f "../assets/lambda.zip" ]; then
        echo "File exists. Deleting..."
        rm ../assets/lambda.zip
      fi
      echo "Creating lambda.zip..."
      zip -r ../assets/lambda.zip ../assets/index.py
    EOT
  }
}
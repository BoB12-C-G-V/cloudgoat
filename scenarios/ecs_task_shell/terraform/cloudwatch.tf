resource "aws_cloudwatch_event_rule" "guardduty_events" {
  name        = "cg-guardduty-events-${var.cgid}"
  description = "Capture ECS API Calls"

  event_pattern = jsonencode({
    "source" : ["aws.guardduty"],
    "detail-type" : ["GuardDuty Finding"],
  })
}

resource "aws_cloudwatch_event_target" "ecs_event_target" {
  rule = aws_cloudwatch_event_rule.guardduty_events.name
  arn  = aws_lambda_function.guardduty_lambda.arn
}

data "aws_guardduty_detector" "guardduty" {}
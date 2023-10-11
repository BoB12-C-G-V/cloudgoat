resource "aws_cloudwatch_event_rule" "ecs_events" {
  name        = "cg-ecs-events-${var.cgid}"
  description = "Capture ECS API Calls"

  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["ecs.amazonaws.com"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecs_event_target" {
  rule      = aws_cloudwatch_event_rule.ecs_events.name
  target_id = "EcsEventTarget"
  arn       = aws_lambda_function.ecs_event_handler.arn
}
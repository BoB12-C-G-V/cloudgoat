
resource "aws_iam_user" "player" {
  name = "player"
  tags = {
    Name     = "player"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "player_access_key" {
  user = aws_iam_user.player.name
}

resource "aws_iam_user_policy_attachment" "name" {
  user       = aws_iam_user.player.name
  policy_arn = aws_iam_policy.iam_policy_tutorial.arn
}

resource "aws_iam_policy" "iam_policy_tutorial" {
  name        = "iam_policy_tutorial"
  description = "for_iam_policy_tutorial"


  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:List*",
            "iam:GetPolicyVersion",
            "iam:CreatePolicyVersion",
          ],
          "Resource" : "*"
        }
      ]
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_user" "player" {
  name = "player-${var.lecture_id}"
  tags = {
    Name     = "player-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}


# 엑세스키 생성
resource "aws_iam_access_key" "player_access_key" {
  user = aws_iam_user.player.name
}



resource "aws_iam_policy" "minimum_policy" {
  name        = "minimum_policy"
  description = "minimum_policy Polic"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "lambda:List*",
            "lambda:GetFunction",
            "iam:List*",
            "iam:Get*",
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


resource "aws_iam_user_policy_attachment" "access_user_policy" {
  user       = aws_iam_user.player.name
  policy_arn = aws_iam_policy.minimum_policy.arn
}


resource "aws_iam_user" "cg-lambda-manager" {
  name = "manager"
  tags = {
    Name     = "player-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

# 엑세스키 생성
resource "aws_iam_access_key" "manager_access_key" {
  user = aws_iam_user.cg-lambda-manager.name
}

resource "aws_iam_policy" "manage_policy" {
  name        = "manage_policy"
  description = "manage_policy Polic"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        }
      ]
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_user_policy_attachment" "access_user_policy" {
  user       = aws_iam_user.cg-lambda-manager.name
  policy_arn = aws_iam_policy.manage_policy.arn
}
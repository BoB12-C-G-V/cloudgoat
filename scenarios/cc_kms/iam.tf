#-----------------starting IAM----------------
resource "aws_iam_user" "cg-bob" {
  name = "bob"
  tags = {
    Name     = "cg-bob-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "cg-bob" {
  user = aws_iam_user.cg-bob.name
}



resource "aws_iam_policy" "code_commit_basic_policy" {
  name        = "code_commit_basic_policy"
  description = "Basic CodeCommit policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetDifferences",
          "codecommit:GetRepository",
          "codecommit:GetRepositoryTriggers",
          "codecommit:GitPull",
          "codecommit:GitPush",
          "codecommit:CreateBranch",
          "codecommit:ListBranches",
          "codecommit:ListRepositories"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_user_policy_attachment" "code_commit_basic_attachment" {
  user       = aws_iam_user.cg-bob.name
  policy_arn = aws_iam_policy.code_commit_basic_policy.arn
}

#-----------------end starting IAM----------------

#------------target IAM----------------
resource "aws_iam_user" "cg-whoru" {
  name = "whoru"
  tags = {
    Name     = "whoru-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "cg-whoru" {
  user = aws_iam_user.cg-whoru.name
}

resource "aws_iam_policy" "AWSCodeCommitPowerUser" {
  name        = "AWSCodeCommitPowerUser"
  description = "AWS CodeCommit Power User Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codecommit:AssociateApprovalRuleTemplateWithRepository",
          "codecommit:BatchAssociateApprovalRuleTemplateWithRepositories",
          "codecommit:BatchDisassociateApprovalRuleTemplateFromRepositories",
          "codecommit:BatchGet*",
          "codecommit:BatchDescribe*",
          "codecommit:Create*",
          "codecommit:DeleteBranch",
          "codecommit:DeleteFile",
          "codecommit:Describe*",
          "codecommit:DisassociateApprovalRuleTemplateFromRepository",
          "codecommit:EvaluatePullRequestApprovalRules",
          "codecommit:Get*",
          "codecommit:List*",
          "codecommit:Merge*",
          "codecommit:OverridePullRequestApprovalRules",
          "codecommit:Put*",
          "codecommit:Post*",
          "codecommit:TagResource",
          "codecommit:Test*",
          "codecommit:UntagResource",
          "codecommit:Update*",
          "codecommit:GitPull",
          "codecommit:GitPush"
        ],
        Resource = "*"
      },
      {
        Sid    = "CloudWatchEventsCodeCommitRulesAccess",
        Effect = "Allow",
        Action = [
          "events:DeleteRule",
          "events:DescribeRule",
          "events:DisableRule",
          "events:EnableRule",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:ListTargetsByRule"
        ],
        Resource = "arn:aws:events:*:*:rule/codecommit*"
      },
      {
        Sid    = "SNSTopicAndSubscriptionAccess",
        Effect = "Allow",
        Action = [
          "sns:Subscribe",
          "sns:Unsubscribe"
        ],
        Resource = "arn:aws:sns:*:*:codecommit*"
      },
      {
        Sid    = "SNSTopicAndSubscriptionReadAccess",
        Effect = "Allow",
        Action = [
          "sns:ListTopics",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_user_policy_attachment" "AWSCodeCommitPowerUserAttachment" {
  user       = aws_iam_user.cg-whoru.name
  policy_arn = aws_iam_policy.AWSCodeCommitPowerUser.arn
}

#------------end target IAM----------------
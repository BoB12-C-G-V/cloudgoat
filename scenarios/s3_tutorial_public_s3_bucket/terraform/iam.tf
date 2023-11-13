

resource "aws_iam_user" "playerA" {
  name = "playerA-${var.lecture_id}"
  tags = {
    Name     = "player-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}


# 엑세스키 생성
resource "aws_iam_access_key" "playerA_access_key" {
  user = aws_iam_user.playerA.name
}



resource "aws_iam_policy" "Access_Bucket_A" {
  name        = "Access_Bucket_A"
  description = "Access_Bucket_A Polic"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "${aws_s3_bucket.player_bucket_a.arn}",
            "${aws_s3_bucket.player_bucket_a.arn}/*"
          ]
        }
      ]
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_user_policy_attachment" "access_user_policy" {
  user       = aws_iam_user.playerA.name
  policy_arn = aws_iam_policy.Access_Bucket_A.arn
}

resource "aws_iam_user_policy_attachment" "Attache_listing_policy" {
  user = aws_iam_user.playerA.name
  policy_arn = aws_iam_policy.JustListBucket.arn
}

resource "aws_iam_user_policy_attachment" "Attache_Policy_listing_policy" {
  user = aws_iam_user.playerA.name
  policy_arn = aws_iam_policy.PolicyListing.arn 
}

resource "aws_iam_user_policy_attachment" "Attache_Policy_listing_policy_to_playerB" {
  user = aws_iam_user.playerB.name
  policy_arn = aws_iam_policy.PolicyListing.arn 
}
#===================================================================================================


resource "aws_iam_user" "playerB" {
  name = "playerB-${var.lecture_id}"
  tags = {
    Name     = "player-${var.lecture_id}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_iam_access_key" "playerB_access_key" {
  user = aws_iam_user.playerB.name
}

resource "aws_iam_policy" "JustListBucket" {
  name        = "JustPutBucket"
  description = "JustPutBucket Polic"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListAllMyBuckets",
            "s3:GetBucketPolicy",
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


resource "aws_iam_user_policy_attachment" "weak_access_user_policy" {
  user       = aws_iam_user.playerB.name
  policy_arn = aws_iam_policy.JustListBucket.arn
}



#===================================================================================================




resource "aws_iam_policy" "PolicyListing" {
  name        = "PolicyListing"
  description = "for_PolicyListing"


  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:ListUsers",
            "iam:ListPolicyVersions",
            "iam:ListattachedUserPolicies",
            "iam:ListPolicies",
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
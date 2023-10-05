#IAM Users
resource "aws_iam_user" "cg-startuser" {
  name = "startuser"
  tags = {
    Name = "cg-startuser-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_iam_user" "cg-scgmod" {
  name = "scgmod"
  tags = {
    Name     = "scgmod-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_iam_access_key" "cg-startuser" {
  user = "${aws_iam_user.cg-startuser.name}"
}
resource "aws_iam_access_key" "cg-scgmod" {
  user = "${aws_iam_user.cg-scgmod.name}"
}
#IAM User Policies
resource "aws_iam_policy" "cg-startuser-policy" {
  name = "cg-startuser-policy"
  description = "cg-startuser-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "elasticloadbalancing:Describe*",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*",
                "autoscaling:Describe*"
            ],
            "Resource": "*"
        },
        {
          	"Effect": 	"Allow",
          	"Action": [
            	"s3:*",
            	"s3-object-lambda:*"
          	],
          	"Resource":"*"
        },
        {
        	  "Sid": "VisualEditor0",
        	  "Effect": "Allow",
        	  "Action": [
            	   "iam:List*",
            	   "iam:Get*"
              ],
              "Resource": "*"
       }
    ]
}
EOF
}

resource "aws_iam_policy" "cg-scgmod-policy" {
  name = "cg-scgmod-policy"
  description = "cg-scgmod-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "elasticloadbalancing:Describe*",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*",
                "autoscaling:Describe*"
            ],
           	"Resource": "*"
        },
        {
        	"Sid":    	"VisualEditor1",
        	"Effect": 	"Allow",
        	"Action":[
            	   	"iam:List*",
            	    "iam:Get*"
          ],
          "Resource": "*"
       },
       {
        	  "Sid": "VisualEditor2",
          	  "Effect": "Allow",
          	  "Action": [
              	      "ec2:RevokeSecurityGroupIngress",
              	      "ec2:RebootInstances",
              	      "ec2:AuthorizeSecurityGroupEgress",
              	      "ec2:AuthorizeSecurityGroupIngress",
              	      "ec2:CreateTags",
                      "ec2:RevokeSecurityGroupEgress"
              ],
             	   "Resource":"*"
      },
      {
            	   "Sid":"VisualEditor3",
                   "Effect":"Allow",
                   "Action":"ec2:Describe Security Groups",
                   "Resource":"*"
      }
    ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "cg-startuser-attachment" {
  user = "${aws_iam_user.cg-startuser.name}"
  policy_arn = "${aws_iam_policy.cg-startuser-policy.arn}"
}

resource "aws_iam_user_policy_attachment" "cg-scgmod-attachment" {
  user = "${aws_iam_user.cg-scgmod.name}"
  policy_arn = "${aws_iam_policy.cg-scgmod-policy.arn}"
}
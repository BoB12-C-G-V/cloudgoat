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
    Name     = "cg-scgmod-${var.cgid}"
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
resource "aws_iam_user_policy_attachment" "cg-startuser-attachment-ec2" {
  user       = "${aws_iam_user.cg-startuser.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "cg-startuser-attachment-s3" {
  user       = "${aws_iam_user.cg-startuser.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy" "cg-ListGet_policy-inline" {
  count  = 2
  name   = "ListGet_policy"
  user   = element(["${aws_iam_user.cg-startuser.name}", "${aws_iam_user.cg-scgmod.name}"], count.index)

  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
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


resource "aws_iam_user_policy" "cg-scgmod-policy-inline" {
    name   = "Securitygroup_mod_policy"
    user   = "${aws_iam_user.cg-scgmod.name}"

    policy=<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RebootInstances",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateTags",
                "ec2:RevokeSecurityGroupEgress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ec2:DescribeSecurityGroups",
            "Resource": "*"
        }
    ]
}
EOF
}
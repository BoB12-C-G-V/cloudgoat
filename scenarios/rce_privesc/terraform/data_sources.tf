#AWS Account Id
data "aws_caller_identity" "aws-account-id" {
  
}
#S3 Full Access Policy
data "aws_iam_policy" "aws-admin-access" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
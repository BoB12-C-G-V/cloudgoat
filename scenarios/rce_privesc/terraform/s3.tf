#Secret S3 Bucket
locals {
  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
  bucket_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

resource "aws_s3_bucket" "cg-cardholder-data-bucket" {
  bucket = "cg-cardholder-data-bucket-${local.bucket_suffix}"
  force_destroy = true
  tags = {
      Name = "cg-cardholder-data-bucket-${local.bucket_suffix}"
      Description = "CloudGoat ${var.cgid} S3 Bucket used for storing sensitive cardholder data."
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}

resource "aws_s3_bucket_acl" "cardholder-data-bucket-acl" {
  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id
  acl    = "private"
  #add 1 line
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_object" "cg-scgmod-credentials" {
  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id
  key    = "secret/scgmod_accessKeys.txt"
  source = "../assets/scgmod_accessKeys.txt"
}

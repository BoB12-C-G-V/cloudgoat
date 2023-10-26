#Secret S3 Bucket
locals {
  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
  bucket_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

resource "aws_s3_bucket" "secret-s3-bucket" {
  bucket        = "cg-s3-${local.bucket_suffix}"
  force_destroy = true
}

# Secret String at flag.txt
resource "aws_s3_object" "credentials" {
  bucket = aws_s3_bucket.secret-s3-bucket.id
  key    = "flag.txt"
  source = "../assets/flag.txt"
}

locals {
  bucket_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

resource "aws_s3_bucket" "secret-s3-bucket" {
  bucket        = "cg-s3-${local.bucket_suffix}"
  force_destroy = true
}

resource "aws_s3_object" "credentials" {
  bucket = aws_s3_bucket.secret-s3-bucket.id
  key    = "flag.txt"
  source = "../assets/flag.txt"
}

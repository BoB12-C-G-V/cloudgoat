resource "aws_s3_bucket" "anyone_bucket" {
  bucket = "bobthtest2"
}


resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.anyone_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.anyone_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  
  depends_on = [ aws_s3_bucket_ownership_controls.ownership, aws_s3_bucket_public_access_block.access_block ]
  bucket = aws_s3_bucket.anyone_bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "public_test_policy" {
  bucket = aws_s3_bucket.anyone_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": ["arn:aws:s3:::bobthtest2/*", "arn:aws:s3:::bobthtest2"]
        }
    ]
})
}


resource "aws_s3_object" "flag_file" {
  bucket = aws_s3_bucket.anyone_bucket.id
  key    = "flag.txt"
  source = "./test.txt"
}
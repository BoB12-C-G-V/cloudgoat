resource "aws_s3_bucket" "player-bucket" {
  bucket = "bpb12th-player-testing" # 버킷 이름을 고유하게 지정하세요.

}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.player-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.add_tag.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }
  depends_on = [aws_lambda_permission.s3_invoke_permission]
}
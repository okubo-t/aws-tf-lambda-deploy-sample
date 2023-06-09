resource "aws_s3_bucket" "artifacts_store" {
  bucket        = "${var.codepipeline_name}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

/*
resource "aws_s3_bucket_acl" "artifacts_store" {
  bucket = aws_s3_bucket.artifacts_store.id
  acl    = "private"
}
*/

resource "aws_s3_bucket_policy" "artifacts_store" {
  bucket = aws_s3_bucket.artifacts_store.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "ArtifactsStorePolicy",
    Statement : [
      {
        Sid : "CodePipelineBucketPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild.arn,
            aws_iam_role.codepipeline_cfn.arn
        ] },
        Action : [
          "s3:Get*",
          "s3:Put*"
        ],
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
      },
      {
        Sid : "CodePipelineBucketListPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild.arn,
            aws_iam_role.codepipeline_cfn.arn
        ] },
        Action : "s3:ListBucket",
        Resource : aws_s3_bucket.artifacts_store.arn,
      }
    ]
  })
}

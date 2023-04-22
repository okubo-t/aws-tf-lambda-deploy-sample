resource "aws_iam_role" "cloudwatch_events" {
  name = var.event_rule_name
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_events" {
  name = var.event_rule_name
  role = aws_iam_role.cloudwatch_events.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codepipeline:StartPipelineExecution"
        ],
        Resource : [
          aws_codepipeline.this.arn
        ],
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline" {
  name = var.codepipeline_name
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codepipeline.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = var.codepipeline_name
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Resource : [
          aws_iam_role.codepipeline_codecommit.arn,
          aws_iam_role.codepipeline_codebuild.arn,
        ],
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_codecommit" {
  name = "${var.codepipeline_name}-codecommit"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "for_repository" {
  name = "${var.codepipeline_name}-repository"
  role = aws_iam_role.codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ],
        Resource : aws_codecommit_repository.this.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "for_artifacts_store" {
  name = "${var.codepipeline_name}-artifacts-store"
  role = aws_iam_role.codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.artifacts_store.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_codebuild" {
  name = "${var.codepipeline_name}-start-codebuild"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_codebuild" {
  name = "${var.codepipeline_name}-start-codebuild"
  role = aws_iam_role.codepipeline_codebuild.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource : [
          aws_codebuild_project.this.arn,
        ],
        Effect : "Allow"
      },
      {
        Action : [
          "logs:CreateLogGroup"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "codebuild" {
  name = "${var.codepipeline_name}-codebuild"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codebuild.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.codepipeline_name}-codebuild"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        Action = [
          "apigateway:*",
          "lambda:*",
          "s3:*",
          "cloudformation:*",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_cfn" {
  name = "${var.codepipeline_name}-cfn"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_cfn" {
  name = "${var.codepipeline_name}-cfn"
  role = aws_iam_role.codepipeline_cfn.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "cloudformation:*",
          "iam:PassRole",
        ],
        Resource = "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "for_artifacts_store_sam_package" {
  name = "${var.codepipeline_name}-artifacts-sam-package"
  role = aws_iam_role.codepipeline_cfn.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.artifacts_store.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "cfn_changeset" {
  name = "${var.codepipeline_name}-cfn-changeset"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cfn_changeset" {
  name = "${var.codepipeline_name}-cfn-changeset"
  role = aws_iam_role.cfn_changeset.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:*",
          "logs:*",
          "s3:*",
          "cloudformation:*",
          "iam:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

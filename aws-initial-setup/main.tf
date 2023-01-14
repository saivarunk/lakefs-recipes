terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.zones.north_virginia
}

resource "aws_s3_bucket" "lakefs_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    name = var.s3_bucket_name
    env  = var.env
  }
}

resource "aws_s3_bucket_acl" "lakefs_bucket" {
  bucket = aws_s3_bucket.lakefs_bucket.id
  acl    = "private"
}

resource "aws_iam_user" "lakefs_user" {
  name = "lakefs_user"
  path = "/system/"

  tags = {
    env = var.env
  }
}

resource "aws_iam_access_key" "lakefs_user" {
  user = aws_iam_user.lakefs_user.name
}

resource "aws_s3_bucket_policy" "lakefs_s3_access" {
  bucket = aws_s3_bucket.lakefs_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "lakeFSObjects",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Effect = "Allow",
        Principal = {
          AWS = ["${aws_iam_user.lakefs_user.arn}"]
        },
        Resource = ["${aws_s3_bucket.lakefs_bucket.arn}/*"]
      },
      {
        Sid = "lakeFSBucket",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ],
        Effect   = "Allow",
        Principal = {
          AWS = ["${aws_iam_user.lakefs_user.arn}"]
        },
        Resource = ["${aws_s3_bucket.lakefs_bucket.arn}"]
      }
    ]
  })
}

resource "aws_iam_user_policy" "lakefs_user_ro" {
  name = "lakefs_user_policy"
  user = aws_iam_user.lakefs_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAndDescribe",
        Effect = "Allow",
        Action = [
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive"
        ],
        Resource = "*"
      },
      {
        Sid    = "kvstore",
        Effect = "Allow",
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem"
        ],
        Resource = "arn:aws:dynamodb:*:*:table/kvstore"
      }
    ]
  })
}

output "access_key" {
  value = aws_iam_access_key.lakefs_user.id
}

output "secret_key" {
  value = nonsensitive(aws_iam_access_key.lakefs_user.secret)
}

resource "aws_s3_bucket" "cache" {
  bucket_prefix = "cache"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:arianvp/nix-s3-demo:*"]
    }
  }
}

data "aws_iam_policy_document" "read_cache" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
    ]
    resources = ["${aws_s3_bucket.cache.arn}/*", aws_s3_bucket.cache.arn]
  }
}

resource "aws_iam_role" "read_cache" {
  name               = "read-cache"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "read-cache"
    policy = data.aws_iam_policy_document.read_cache.json
  }
}

data "aws_iam_policy_document" "write_cache" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.cache.arn}/*", aws_s3_bucket.cache.arn]
  }
}

resource "aws_iam_role" "write_cache" {
  name               = "write-cache"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "write-cache"
    policy = data.aws_iam_policy_document.write_cache.json
  }
}

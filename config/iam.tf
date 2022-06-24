resource "aws_iam_role" "execution_role" {
  name = "iam_for_lambda-${var.namespace}-${local.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid = "WriteCloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${local.aws_region}:${local.acctid}:log-group:/aws/lambda/*:*"
    ]
  }
  statement {
    sid = "UpdateTagsAll"
    actions = [
      "tag:CreateTags",
      "tag:DeleteTags",
      "tag:Get*",
      "tag:TagResources",
      "tag:UntagResources"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
  statement {
    sid = "UpdateTagsALB"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:RemoveTags",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:${local.aws_region}:${local.acctid}:loadbalancer/*",
      "arn:aws:elasticloadbalancing:${local.aws_region}:${local.acctid}:targetgroup/*"
    ]
  }
  statement {
    sid = "UpdateTagsRDS"
    actions = [
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:RemoveTagsFromResource"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:rds:${local.aws_region}:${local.acctid}:db:*"
    ]
  }
  statement {
    sid = "UpdateTagsEC2"
    actions = [
      "ec2:Describe*",
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:${local.aws_region}:${local.acctid}:*/*"
    ]
  }
  statement {
    sid = "UpdateTagsSQS"
    actions = [
      "sqs:ListQueueTags",
      "sqs:TagQueue",
      "sqs:UntagQueue",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:sqs:${local.aws_region}:${local.acctid}:*/*"
    ]
  }
  statement {
    sid = "UpdateTagsS3"
    actions = [
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:DeleteBucketTagging",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::*"
    ]
  }
  statement {
    sid = "UpdateTagsRedshift"
    actions = [
      "redshift:CreateTags",
      "redshift:DeleteTags",
      "redshift:DescribeTags",
      "redshift:Tag",
      "redshift:TaggedResource",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:redshift:${local.aws_region}:${local.acctid}:*/*"
    ]
  }
  statement {
    sid = "UpdateTagsDynamodb"
    actions = [
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:ListTagsOfResource",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:dynamodb:${local.aws_region}:${local.acctid}:*/*"
    ]
  }
}

resource "aws_iam_policy" "execution_role" {
  name   = "lambda-role-${var.namespace}-${local.aws_region}"
  path   = "/"
  policy = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.execution_role.arn
}

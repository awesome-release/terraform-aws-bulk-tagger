data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  acctid     = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}

variable "namespace" {
  type        = string
  description = "Namespace to avoid collisions in one account"
  default     = "lambda_bulk_tagger"
}

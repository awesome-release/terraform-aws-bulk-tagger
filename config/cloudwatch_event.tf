locals {
  function_qualified_arn = module.lambda_bulk_tagger.function_qualified_arn
  function_name          = regex("[:]([^:]+)[:][0-9]+$", local.function_qualified_arn)[0]
  function_qualifier     = regex("[:]([0-9]+)$", local.function_qualified_arn)[0]
}

module "lambda-cloudwatch-trigger-rds" {
  source = "./cloudwatch-module/"

  namespace = "RDS"
  lambda_input = jsonencode({
    "TagFilters" = [
      {
        "Key" = "releasehub.com/rds-pool",
        "Values" = [
          "true"
        ]
      }
    ],
    "TagsToApply" = {
      "VantaNonProd"          = "true",
      "VantaDescription"      = "RDS Pool Dev Instance",
      "VantaContainsUserData" = "false",
      "VantaNoAlert"          = "Pool instances for development work: no backups required and no user data stored."
    },
    "ResourceTypeFilters" = [
      "rds"
    ]
  })
  lambda_arn                 = local.function_qualified_arn
  lambda_function_name       = local.function_name
  lambda_qualifier           = local.function_qualifier
  lambda_schedule_expression = "rate(57 minutes)"
}

module "lambda-cloudwatch-trigger-alb-preprod" {
  source = "./cloudwatch-module/"

  namespace = "ALB-preprod"
  lambda_input = jsonencode({
    "MustMatchAllTagFilters" = "false",
    "TagFilters" = [
      {
        "Key" = "kubernetes.io/cluster/preprod",
        "Values" = [
          "owned"
        ]
      },
      {
        "Key" = "kubernetes.io/cluster/development",
        "Values" = [
          "owned"
        ]
      }
    ],
    "TagsToApply" = {
      "VantaNonProd"          = "true",
      "VantaDescription"      = "Load Balancer in AWS",
      "VantaContainsUserData" = "false",
      "VantaNoAlert"          = "Serves traffic for non-prod instances. Does not require monitoring and does not affect customers."
    },
    "ResourceTypeFilters" = [
      "elasticloadbalancing"
    ]
  })
  lambda_arn                 = local.function_qualified_arn
  lambda_function_name       = local.function_name
  lambda_qualifier           = local.function_qualifier
  lambda_schedule_expression = "rate(57 minutes)"
}

module "lambda-cloudwatch-trigger-alb-prod" {
  source = "./cloudwatch-module/"

  namespace = "ALB-prod"
  lambda_input = jsonencode({
    "MustMatchAllTagFilters" = "false",
    "TagFilters" = [
      {
        "Key" = "kubernetes.io/cluster/release-prod-us-west-2",
        "Values" = [
          "owned"
        ]
      },
    ],
    "TagsToApply" = {
      "VantaDescription"      = "Load Balancer in AWS",
      "VantaOwner"            = "owner@example.com"
    },
    "ResourceTypeFilters" = [
      "elasticloadbalancing"
    ]
  })
  lambda_arn                 = local.function_qualified_arn
  lambda_function_name       = local.function_name
  lambda_qualifier           = local.function_qualifier
  lambda_schedule_expression = "rate(57 minutes)"
}

module "lambda-cloudwatch-trigger-owners" {
  source = "./cloudwatch-module/"

  namespace = "owners"
  lambda_input = jsonencode({
    "TagKeyExclusion" = "VantaOwner",
    "TagFilters" = [],
    "TagsToApply" = {
      "VantaOwner"            = "owner@example.com"
    },
    "ResourceTypeFilters" = [
      "elasticloadbalancing",
      "ec2:instance",
      "s3",
      "rds",
      "redshift",
      "dynamodb",
      "sqs",
    ]
  })
  lambda_arn                 = local.function_qualified_arn
  lambda_function_name       = local.function_name
  lambda_qualifier           = local.function_qualifier
  lambda_schedule_expression = "rate(57 minutes)"
}

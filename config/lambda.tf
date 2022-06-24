module "lambda_bulk_tagger" {
  source = "./lambda-module/"

  function_name       = var.namespace
  function_dirname    = var.namespace
  lambda_iam_role_arn = aws_iam_role.execution_role.arn
}

output "lambda_qualified_arn" {
  value = module.lambda_bulk_tagger.function_qualified_arn
}

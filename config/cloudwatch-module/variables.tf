variable "lambda_arn" {
  type        = string
  description = "Lambda ARN"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_qualifier" {
  type        = string
  description = "The lambda specific qualifier to run."
}

variable "lambda_schedule_expression" {
  type        = string
  description = "Lambda schedule expression. Defaults to every 5 minutes"
  default     = "rate(5 minutes)"
}

variable "lambda_input" {
  type        = string
  description = "Valid JSON object to send to Lambda."
  default     = "{}"
}

variable "namespace" {
  type        = string
  description = "The namespace for this cloudwatch event"
}

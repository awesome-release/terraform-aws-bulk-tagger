variable "function_name" {
  type        = string
  description = "The name of the lambda function"
}

variable "function_dirname" {
  type        = string
  description = "The directory for the lambda function"
}

variable "memory_size" {
  type        = number
  description = "The amount of KBi to use."
  default     = 256
}

variable "timeout" {
  type        = number
  description = "The number of seconds before lambda will timeout."
  default     = 600
}

variable "lambda_iam_role_arn" {
  type        = string
  description = "The ARN for the lambda execution role."
}

variable "handler" {
  type        = string
  description = "The name of the function handler entrypoint."
  default     = "handler.bulk_tagger"
}

variable "runtime" {
  type        = string
  description = "The name of the runtime interpreter."
  default     = "python3.8"
}

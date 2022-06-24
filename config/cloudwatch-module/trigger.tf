#####
# Stolen from https://github.com/infrablocks/terraform-aws-lambda-cloudwatch-events-trigger/blob/master/trigger.tf
#####

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.lambda_function_name}-${var.namespace}"
  schedule_expression = var.lambda_schedule_expression
}

resource "aws_cloudwatch_event_target" "check_at_rate" {
  rule  = aws_cloudwatch_event_rule.event_rule.name
  arn   = var.lambda_arn
  input = var.lambda_input
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch-${var.namespace}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
  qualifier     = var.lambda_qualifier
}

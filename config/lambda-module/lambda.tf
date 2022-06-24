locals {
  output_filename = "/var/tmp/${var.function_name}.zip"
  source_dir      = "${path.module}/src/${var.function_dirname}"
}

resource "null_resource" "build" {
  triggers = {
    handler          = filebase64sha256("${local.source_dir}/handler.py")
    notifier         = filebase64sha256("${local.source_dir}/notifier.py")
    response_manager = filebase64sha256("${local.source_dir}/responseManager.py")
  }

  provisioner "local-exec" {
    working_dir = local.source_dir
    command     = <<localexec
( flock -w 30 9 && \
python3 -m py_compile *.py && \
rm -f ${local.output_filename} && \
zip -rq ${local.output_filename} *.py __pycache__ && \
true || exit 1 ) 9> ${local.output_filename}.lock
localexec
  }
}

data "template_file" "zipfile" {
  template = filebase64sha256(local.output_filename)
  vars = {
    id = null_resource.build.id
  }
}

resource "aws_lambda_function" "this" {
  filename         = local.output_filename
  description      = "Created by terraform"
  memory_size      = var.memory_size
  timeout          = var.timeout
  function_name    = var.function_name
  role             = var.lambda_iam_role_arn
  handler          = var.handler
  runtime          = var.runtime
  publish          = true
  source_code_hash = data.template_file.zipfile.rendered

  tags = {
    purpose   = "compliance-bulk-tagger"
    ddmonitor = "false"
    build_id  = null_resource.build.id
  }
}

output "function_qualified_arn" {
  value = aws_lambda_function.this.qualified_arn
}

# Add these variables to stack1-aws/variables.tf

variable "enable_auto_shutdown" {
  type        = bool
  default     = true
  description = "Enable auto-shutdown for cost savings (lab environments only)"
}

variable "auto_shutdown_time" {
  type        = string
  default     = "18:00"
  description = "Auto-shutdown time in HH:MM format (24-hour)"
}

variable "auto_shutdown_timezone" {
  type        = string
  default     = "Europe/London"
  description = "Timezone for auto-shutdown"
}

variable "auto_shutdown_notification_email" {
  type        = string
  default     = ""
  description = "Email for shutdown notifications (optional)"
}

# Add to the end of stack1-aws/main.tf

# Lambda function for auto-shutdown
resource "aws_iam_role" "shutdown_lambda_role" {
  count = var.enable_auto_shutdown ? 1 : 0
  name  = "${var.name_prefix}-shutdown-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "shutdown_lambda_policy" {
  count = var.enable_auto_shutdown ? 1 : 0
  name  = "${var.name_prefix}-shutdown-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "shutdown_lambda_policy_attach" {
  count      = var.enable_auto_shutdown ? 1 : 0
  role       = aws_iam_role.shutdown_lambda_role[0].name
  policy_arn = aws_iam_policy.shutdown_lambda_policy[0].arn
}

# Lambda function for shutdown
resource "aws_lambda_function" "auto_shutdown" {
  count         = var.enable_auto_shutdown ? 1 : 0
  filename      = "shutdown_lambda.zip"
  function_name = "${var.name_prefix}-auto-shutdown"
  role          = aws_iam_role.shutdown_lambda_role[0].arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.shutdown_lambda_zip[0].output_base64sha256

  environment {
    variables = {
      TAG_KEY   = "AutoShutdown"
      TAG_VALUE = "Enabled"
    }
  }
}

# Create Lambda deployment package
data "archive_file" "shutdown_lambda_zip" {
  count       = var.enable_auto_shutdown ? 1 : 0
  type        = "zip"
  output_path = "shutdown_lambda.zip"

  source {
    content = <<EOF
import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    # Get instances with AutoShutdown tag
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:${var.name_prefix}',
                'Values': ['*']
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )

    instance_ids = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])

    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped instances: {instance_ids}")
    else:
        print("No running instances found to stop")

    return {
        'statusCode': 200,
        'body': f'Processed {len(instance_ids)} instances'
    }
EOF
    filename = "lambda_function.py"
  }
}

# EventBridge rule for daily shutdown
resource "aws_cloudwatch_event_rule" "daily_shutdown" {
  count               = var.enable_auto_shutdown ? 1 : 0
  name                = "${var.name_prefix}-daily-shutdown"
  description         = "Trigger auto-shutdown daily"
  schedule_expression = "cron(${split(":", var.auto_shutdown_time)[1]} ${split(":", var.auto_shutdown_time)[0]} * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.enable_auto_shutdown ? 1 : 0
  rule  = aws_cloudwatch_event_rule.daily_shutdown[0].name
  arn   = aws_lambda_function.auto_shutdown[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.enable_auto_shutdown ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_shutdown[0].arn
}
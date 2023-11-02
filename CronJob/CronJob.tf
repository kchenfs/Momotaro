# Configure the AWS provider
provider "aws" {
  region = "ca-central-1" # Set your desired AWS region
}

# Reference the existing SES email identity
data "aws_ses_email_identity" "sender" {
  email = "kencfs@outlook.com"
}

# Create an AWS Lambda execution role
resource "aws_iam_role" "my_lambda_role" {
  name = "my-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "my_lambda_function" {
  s3_bucket     = "momotaropackage"
  s3_key        = "CronJob.zip"
  function_name = "CronJob"
  role          = aws_iam_role.my_lambda_role.arn
  handler       = "your_script.lambda_handler" # Replace with your Python script's handler function
  runtime       = "python3.11"                 # Set your desired Python version
  timeout       = 60                          # Adjust as needed


  environment {
    variables = {
      # Add your environment variables here if needed
    }
  }

}
resource "aws_iam_policy_attachment" "lambda_cloudwatch_policy_attachments" {
  name = "test-user"
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
  roles      = [aws_iam_role.my_lambda_role.name]
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.my_lambda_function.function_name}"
}

# Schedule the Lambda function to run using CloudWatch Events (adjust schedule as needed)
resource "aws_cloudwatch_event_rule" "my_event_rule" {
  name                = "my-event-rule"
  description         = "Scheduled Lambda execution"
  schedule_expression = "cron(0 5 * * ? *)" # Runs daily at 5 AM UTC
}

resource "aws_cloudwatch_event_target" "my_event_target" {
  rule      = aws_cloudwatch_event_rule.my_event_rule.name
  target_id = "my-target"
  arn       = aws_lambda_function.my_lambda_function.arn
}

# Grant permissions for CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "my_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn   = aws_cloudwatch_event_rule.my_event_rule.arn
}
resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "lambda-cloudwatch-policy"
  description = "IAM policy for Lambda function to write CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.lambda_log_group.arn,
      },
    ],
  })
}


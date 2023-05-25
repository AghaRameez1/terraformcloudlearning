resource "aws_dynamodb_table_item" "item" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key
  item       = <<Item
    {
        "user":{"S":"AghaRameez"}
    }
    Item

}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name             = "AghaRameezTable"
  billing_mode     = "PROVISIONED"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "user"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  attribute {
    name = "user"
    type = "S"
  }

  tags = {
    Name        = "${var.tags}-dynamodb-table-1"
    Environment = "staging"
  }
}
resource "aws_sns_topic" "dynamoLambdaSNS" {
  name = "dynamoLambdaSNS"
}

resource "aws_iam_role" "dynamoLambda" {
  name               = "dynamoLambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaAssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambdaSQSIam" {
  name               = "lambdaSQSIam"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaAssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "dynamodb_read_log_policy" {
  name   = "lambda-dynamodb-log-policy"
  role   = aws_iam_role.dynamoLambda.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action":[
        "*"
      ],
      "Resource":["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaSNS" {
  name   = "LambdaSNS"
  role   = aws_iam_role.lambdaSQSIam.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      
      "Action":["*"],
      "Effect":"Allow",
      "Resource":["*"]
    }
  ]
}
EOF
}



data "archive_file" "lambda" {
  type        = "zip"
  source_file = "src/lambda.js"
  output_path = "src/lambda_function_payload.zip"
}

resource "aws_lambda_function" "dynamolambda" {
  function_name    = "dynamolambda"
  filename         = "src/lambda_function_payload.zip"
  role             = aws_iam_role.dynamoLambda.arn
  handler          = "lambda.handler"
  runtime          = "nodejs16.x"
  timeout          = 30
  source_code_hash = data.archive_file.lambda.output_base64sha256
  vpc_config {
    subnet_ids         = [values(var.private_subnet_id)[0].id]
    security_group_ids = [var.agharameezSG.id]
  }
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.dynamoLambdaSNS.arn
    }
  }
  tags = {
    Name = "${var.tags}-lambda"
  }
}

data "archive_file" "lambdaSQS" {
  type        = "zip"
  source_file = "src/lambdaSQS.js"
  output_path = "src/lambdaSQS_payload.zip"
}

resource "aws_lambda_function" "SQSlambda" {
  function_name    = "SQSlambda"
  filename         = "src/lambdaSQS_payload.zip"
  role             = aws_iam_role.lambdaSQSIam.arn
  handler          = "lambdaSQS.handler"
  runtime          = "nodejs16.x"
  timeout          = 30
  source_code_hash = data.archive_file.lambdaSQS.output_base64sha256
  vpc_config {
    subnet_ids         = [values(var.private_subnet_id)[0].id]
    security_group_ids = [var.agharameezSG.id]
  }
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.Emailtopic.arn
    }
  }
  tags = {
    Name = "${var.tags}-lambda"
  }
}


resource "aws_lambda_event_source_mapping" "agharameezEvent" {
  event_source_arn  = aws_dynamodb_table.basic-dynamodb-table.stream_arn
  function_name     = aws_lambda_function.dynamolambda.arn
  starting_position = "LATEST"
}


resource "aws_sqs_queue" "agharameezSQS" {
  name                      = "agharameezSQS"
  delay_seconds             = 30
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 1
  sqs_managed_sse_enabled   = false
  policy                    = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
    "Action":["*"],
    "Effect":"Allow",
    "Resource":["*"]
}]
}
EOF
  tags = {
    Name = "${var.tags}-SQS"
  }
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.dynamoLambdaSNS.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.agharameezSQS.arn
}
resource "aws_lambda_event_source_mapping" "SQSLAMBDA" {
  event_source_arn = aws_sqs_queue.agharameezSQS.arn
  function_name    = aws_lambda_function.SQSlambda.arn
}
resource "aws_sns_topic" "Emailtopic" {
  name = "EmailTopic"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.Emailtopic.arn
  protocol  = "email"
  endpoint  = "agha.rameez@eurustechnologies.com"
}

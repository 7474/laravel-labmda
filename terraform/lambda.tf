resource "aws_lambda_function" "web" {
  function_name = "${var.name}-web"

  role = aws_iam_role.lambda.arn

  package_type = "Image"
  image_uri    = "854403262515.dkr.ecr.ap-northeast-1.amazonaws.com/laravel-lambda:master"
  image_config {
    entry_point = ["/lambda-entrypoint.sh"]
    command     = ["public/index.php"]
  }

  environment {
    variables = {
      APP_KEY = var.laravel_app_key
      # DB_HOST     = module.aurora.cluster_endpoint
      # DB_DATABASE = module.aurora.cluster_database_name
      # DB_USERNAME = module.aurora.cluster_master_username
      # DB_PASSWORD = module.aurora.cluster_master_password
      LOG_CHANNEL = "stderr"
    }
  }
}

resource "aws_lambda_function_url" "web" {
  function_name      = aws_lambda_function.web.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pull_ecr" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_pull_ecr.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_pull_ecr" {
  name   = "${var.name}-lambda-pull"
  policy = data.aws_iam_policy_document.lambda_pull_ecr.json
}

# Ref. arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess
data "aws_iam_policy_document" "lambda_pull_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = [
      aws_ecr_repository.this.arn
    ]
  }
}

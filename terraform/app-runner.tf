resource "aws_apprunner_service" "this" {
  service_name = var.name

  source_configuration {
    # It's annoying to pay $1/month.
    auto_deployments_enabled = false
    image_repository {
      image_configuration {
        port = "80"
        runtime_environment_variables = {
          APP_KEY     = var.laravel_app_key
          DB_HOST     = module.aurora.cluster_endpoint
          DB_DATABASE = module.aurora.cluster_database_name
          DB_USERNAME = module.aurora.cluster_master_username
          DB_PASSWORD = module.aurora.cluster_master_password
          LOG_CHANNEL = "stderr"
        }
      }
      image_identifier      = "854403262515.dkr.ecr.ap-northeast-1.amazonaws.com/laravel-lambda:master"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.lambda_pull_ecr.arn
    }
  }
}

resource "aws_iam_role" "lambda_pull_ecr" {
  name = "${var.name}-lambda-pull"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pull_ecr" {
  role       = aws_iam_role.lambda_pull_ecr.name
  policy_arn = aws_iam_policy.lambda_pull_ecr.arn
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

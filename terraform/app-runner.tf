
resource "aws_iam_role" "app_runner_pull_ecr" {
  name = "${var.name}-app-runner-pull"

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

resource "aws_iam_role_policy_attachment" "app_runner_pull_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.app_runner_pull_ecr.arn
}

resource "aws_iam_policy" "app_runner_pull_ecr" {
  name   = "${var.name}-app-runner-pull"
  policy = data.aws_iam_policy_document.app_runner_pull_ecr.json
}

# Ref. arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess
data "aws_iam_policy_document" "app_runner_pull_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = [
      aws_ecr_repository.this.arn
    ]
  }
}
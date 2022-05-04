
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:7474/laravel-app-runner:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name   = "${var.name}-github-actions-ecr-push"
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
  statement {
    sid    = "AllowPushImage"
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [aws_ecr_repository.this.arn]
  }

  statement {
    sid    = "AllowLoginToECR"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_app_runner" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_app_runner.arn
}

resource "aws_iam_policy" "github_actions_app_runner" {
  name   = "${var.name}-github-actions-app-runner"
  policy = data.aws_iam_policy_document.github_actions_app_runner.json
}

data "aws_iam_policy_document" "github_actions_app_runner" {
  statement {
    sid    = "AllowPushImage"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["apprunner.amazonaws.com"]
    }
  }

  statement {
    sid    = "AppRunnerAdminAccess"
    effect = "Allow"
    actions = [
      "apprunner:*"
    ]
    resources = [aws_apprunner_service.this.arn]
  }
}

# GitHub Actions OIDC provider + IAM role for this repo.

locals {
  github_org  = "DouglasFriedmann"
  github_repo = "eks-oidc-observability"

  # Restrict to main branch only
  github_sub = "repo:${local.github_org}/${local.github_repo}:ref:refs/heads/main"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = local.tags
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_sub]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${local.name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
  tags               = local.tags
}

data "aws_iam_policy_document" "github_actions_least_privilege" {
  statement {
    sid    = "AllowEcrLogin"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowPushToAppRepository"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      aws_ecr_repository.app.arn
    ]
  }

  statement {
    sid    = "AllowDescribeEksCluster"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = [
      module.eks.cluster_arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_least_privilege" {
  name   = "${local.name}-github-actions-least-privilege"
  policy = data.aws_iam_policy_document.github_actions_least_privilege.json
}

resource "aws_iam_role_policy_attachment" "github_actions_least_privilege" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_least_privilege.arn
}

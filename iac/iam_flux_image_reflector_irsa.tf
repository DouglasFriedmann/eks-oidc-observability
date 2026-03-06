data "aws_iam_policy_document" "flux_image_reflector_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:flux-system:image-reflector-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "flux_image_reflector_ecr_read" {
  name        = "${local.name}-flux-image-reflector-ecr-read"
  description = "Allow Flux image-reflector-controller to read ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRRead"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "flux_image_reflector" {
  name               = "${local.name}-flux-image-reflector"
  assume_role_policy = data.aws_iam_policy_document.flux_image_reflector_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "flux_image_reflector_ecr_read" {
  role       = aws_iam_role.flux_image_reflector.name
  policy_arn = aws_iam_policy.flux_image_reflector_ecr_read.arn
}

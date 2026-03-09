data "aws_iam_policy_document" "fluent_bit_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:fluent-bit"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "fluent_bit_cloudwatch" {
  statement {
    sid    = "FluentBitCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "fluent_bit_cloudwatch" {
  name   = "${local.name}-fluent-bit-cloudwatch"
  policy = data.aws_iam_policy_document.fluent_bit_cloudwatch.json
}

resource "aws_iam_role" "fluent_bit_irsa" {
  name               = "${local.name}-fluent-bit-irsa"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch" {
  role       = aws_iam_role.fluent_bit_irsa.name
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch.arn
}

output "fluent_bit_irsa_role_arn" {
  value = aws_iam_role.fluent_bit_irsa.arn
}

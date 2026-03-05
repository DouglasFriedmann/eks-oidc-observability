terraform {
  backend "s3" {
    bucket         = "eks-oidc-observability-dev-tfstate-161230539245"
    key            = "eks-oidc-observability/dev-remote/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-oidc-observability-dev-tflock"
    encrypt        = true
  }
}

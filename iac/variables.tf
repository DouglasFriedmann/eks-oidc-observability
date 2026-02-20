variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project" {
  type    = string
  default = "eks-oidc-observability"
}
variable "env" {
  type    = string
  default = "dev"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

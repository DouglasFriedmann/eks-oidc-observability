output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tflock_table" {
  value = aws_dynamodb_table.tflock.name
}

output "backend_key" {
  value = "${var.project}/${var.env}/terraform.tfstate"
}

aws_region          = "eu-central-1"
s3_bucket_name      = "b2c-ciam-tfstate-nonprod"
dynamodb_table_name = "b2c-ciam-tflocks-nonprod"

global_tags = {
  Environment = "non-prod"
  Layer       = "bootstrap"
  ManagedBy   = "Terraform"
  Project     = "B2C-CIAM-Test1-RHDS"
}

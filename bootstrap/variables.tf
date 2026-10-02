variable "aws_region" {
  type        = string
  description = "Target deployment region for state infrastructure"
}

variable "s3_bucket_name" {
  type        = string
  description = "Globally unique name for the state storage S3 container"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name for the concurrent state locking DynamoDB table"
}

variable "global_tags" {
  type        = map(string)
  description = "Standardised environment tracking markers"
}

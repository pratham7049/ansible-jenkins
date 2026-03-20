variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state (must be globally unique)"
  type        = string
  # Replace 'your-unique-bucket-name' with a globally unique name
  default     = "ecs-project-terraform-state-bucket-unique"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "ecs-project-terraform-state-locks"
}

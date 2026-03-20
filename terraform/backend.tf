# Once you have applied the bootstrap configuration, 
# rename this file to `backend.tf` to start using the remote backend.
# Make sure the bucket name and dynamodb_table matched what was created limit bootstrap.

terraform {
  backend "s3" {
    bucket         = "ecs-project-terraform-state-bucket-unique"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecs-project-terraform-state-locks"
    encrypt        = true
  }
}

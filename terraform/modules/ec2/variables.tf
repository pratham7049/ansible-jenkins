variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "public_key_path" {
  description = "Path to public key"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "Allowed SSH IP"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "project_name" {
  description = "Name of the project to be used as prefix for tags"
  type        = string
}

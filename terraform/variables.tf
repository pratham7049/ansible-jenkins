variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  default     = "ami-0ec10929233384c7f"
}

variable "key_name" {
  description = "Key pair name"
  default     = "ansible-key"
}

variable "public_key_path" {
  description = "Path to public key"
  default     = "../keys/ansible-key.pub"
}

variable "allowed_ssh_ip" {
  description = "Allowed SSH IP"
  default     = "0.0.0.0/0"
}
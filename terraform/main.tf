provider "aws" {
  region = var.region
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.region
  project_name       = var.project_name
}

module "ec2" {
  source          = "./modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  public_key_path = var.public_key_path
  allowed_ssh_ip  = var.allowed_ssh_ip
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  project_name    = var.project_name
}

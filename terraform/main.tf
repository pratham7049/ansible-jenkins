provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  subnet_ids       = module.vpc.private_subnet_ids
  cluster_sg_id    = module.security.eks_cluster_sg_id
  node_sg_id       = module.security.eks_nodes_sg_id
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_group_role_arn
  instance_types   = var.instance_types
  desired_capacity = var.eks_desired_capacity
  min_size         = var.eks_min_size
  max_size         = var.eks_max_size
}

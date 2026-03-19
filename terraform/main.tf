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

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  project_name      = var.project_name
}

module "ecs" {
  source                = "./modules/ecs"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_sg_id             = module.security.ecs_sg_id
  target_group_arn      = module.alb.target_group_arn
  listener_arn          = module.alb.listener_arn
  instance_profile_name = module.iam.ecs_instance_profile_name
  task_exec_role_arn    = module.iam.ecs_task_execution_role_arn
  instance_type         = var.instance_type
  desired_capacity      = var.ecs_desired_capacity
  min_size              = var.ecs_min_size
  max_size              = var.ecs_max_size

  depends_on = [module.alb]
}

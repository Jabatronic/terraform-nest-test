# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  environment     = var.environment
  repository_name = var.repository_name
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  certificate_arn   = var.certificate_arn
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecr_repository_url    = module.ecr.repository_url
  alb_target_group_arn  = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  aws_region            = var.aws_region
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  environment        = var.environment
  ecr_repository_arn = module.ecr.repository_arn
}

# CodeBuild Module
module "codebuild" {
  source = "./modules/codebuild"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  codebuild_role_arn  = module.iam.codebuild_role_arn
  aws_region          = var.aws_region
  aws_account_id      = var.aws_account_id
  ecr_repository_name = module.ecr.repository_name
  github_repo_url     = var.github_repo_url
}

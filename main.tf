# Provider e Backend
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-bucket-556000333443-us-east-1-an"
    key            = "projeto-ha/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================
# MÓDULOS
# ============================================

# Módulo VPC
module "vpc" {
  source = "./modules/vpc"

  name_prefix = var.name_prefix
  cidr_block  = var.vpc_cidr
  subnets     = var.subnet_config
  tags        = var.common_tags
}

# Módulo Load Balancer (cria seu próprio SG)
module "loadbalancer" {
  source = "./modules/loadbalancer"

  name_prefix         = var.name_prefix
  app_port            = var.app_port
  health_check_path   = var.health_check_path
  deletion_protection = var.deletion_protection
  common_tags         = var.common_tags
  subnet_ids          = module.vpc.public_subnet_ids
  vpc_id              = module.vpc.vpc_id
  alb_cidr_blocks     = var.alb_allowed_cidrs

  depends_on = [module.vpc]
}

# Módulo Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  name_prefix        = var.name_prefix
  vpc_id             = module.vpc.vpc_id
  alb_sg_id          = module.loadbalancer.alb_sg_id
  private_cidr_block = var.vpc_cidr
  app_port           = var.app_port
  alb_cidr_blocks    = var.alb_allowed_cidrs
  tags               = var.common_tags

  depends_on = [module.loadbalancer]
}

# Módulo Instances (NAT, LT, ASG, IAM)
module "instances" {
  source = "./modules/instances"

  name_prefix               = var.name_prefix
  public_subnet_id          = module.vpc.public_subnet_ids[0]
  private_subnet_ids        = module.vpc.private_subnet_ids
  app_sg_id                 = module.security_groups.app_sg_id
  nat_sg_id                 = module.security_groups.nat_sg_id
  key_name                  = aws_key_pair.minha_chave.key_name
  nat_instance_type         = var.nat_instance_type
  app_instance_type         = var.app_instance_type
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  user_data_path            = var.nat_user_data_path
  app_user_data_path        = var.app_user_data_path
  tags                      = var.common_tags

  depends_on = [module.security_groups]
}

# Key Pair
resource "aws_key_pair" "minha_chave" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

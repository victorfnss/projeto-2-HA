# ============================================
# OUTPUTS DA INFRAESTRUTURA
# ============================================

# VPC
output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR da VPC"
  value       = var.vpc_cidr
}

# Subnets
output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

# Security Groups
output "app_sg_id" {
  description = "ID do security group da aplicação"
  value       = module.security_groups.app_sg_id
}

output "alb_sg_id" {
  description = "ID do security group do ALB"
  value       = module.security_groups.alb_sg_id
}

output "nat_sg_id" {
  description = "ID do security group da NAT"
  value       = module.security_groups.nat_sg_id
}

# Instances
output "nat_instance_id" {
  description = "ID da NAT Instance"
  value       = module.instances.nat_instance_id
}

output "app_asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = module.instances.app_asg_name
}

output "app_launch_template_id" {
  description = "ID do Launch Template"
  value       = module.instances.app_launch_template_id
}

# Load Balancer
output "alb_dns_name" {
  description = "DNS do Load Balancer para acessar a aplicação"
  value       = module.loadbalancer.alb_dns_name
}

output "alb_arn" {
  description = "ARN do Load Balancer"
  value       = module.loadbalancer.alb_arn
}

# IAM
output "ssm_role_arn" {
  description = "ARN do IAM Role para SSM"
  value       = module.instances.ssm_role_arn
}

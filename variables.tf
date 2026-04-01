# Configurações Gerais
variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para tags"
  type        = string
  default     = "projeto-ha"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefixo para todos os recursos (ex: projeto-ha)"
  type        = string
  default     = "projeto-ha"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "O valor deve ser um CIDR válido."
  }
}

variable "subnet_config" {
  description = "Configuração das subnets"
  type = map(object({
    az     = string
    index  = number
    public = bool
  }))
  default = {
    pub_a  = { az = "us-east-1a", index = 1, public = true }
    pub_b  = { az = "us-east-1b", index = 2, public = true }
    priv_a = { az = "us-east-1a", index = 3, public = false }
    priv_b = { az = "us-east-1b", index = 4, public = false }
  }
}

# Application Configuration
variable "app_port" {
  description = "Porta da aplicação"
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "A porta deve estar entre 1 e 65535."
  }
}

variable "app_instance_type" {
  description = "Tipo da instância da aplicação"
  type        = string
  default     = "t3.micro"
}

variable "nat_instance_type" {
  description = "Tipo da instância NAT"
  type        = string
  default     = "t3.micro"
}

# Auto Scaling Configuration
variable "desired_capacity" {
  description = "Capacidade desejada do ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Tamanho máximo do ASG"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Tamanho mínimo do ASG"
  type        = number
  default     = 1
}

variable "health_check_grace_period" {
  description = "Período de graça para health check (segundos)"
  type        = number
  default     = 300
}

# Security Configuration
variable "alb_allowed_cidrs" {
  description = "CIDRs permitidos para acesso ao ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "Nome da chave SSH para as instâncias"
  type        = string
  default     = "projeto-aws-key"
}

variable "public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/projeto-aws-key.pub"
}

# User Data Paths
variable "nat_user_data_path" {
  description = "Caminho para o script user_data da NAT"
  type        = string
  default     = "./user_data/nat_instance.sh"
}

variable "app_user_data_path" {
  description = "Caminho para o script user_data da aplicação"
  type        = string
  default     = "./user_data/script_inicial.sh"
}

# Common Tags
variable "common_tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

# Load Balancer Configuration
variable "health_check_path" {
  description = "Caminho para health check do ALB"
  type        = string
  default     = "/"
}

variable "deletion_protection" {
  description = "Habilitar proteção de exclusão no ALB"
  type        = bool
  default     = true
}

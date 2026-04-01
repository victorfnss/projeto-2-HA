variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
}

variable "app_port" {
  description = "Porta da aplicação"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Caminho para health check"
  type        = string
  default     = "/"
}

variable "deletion_protection" {
  description = "Habilitar proteção de exclusão"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}

variable "alb_cidr_blocks" {
  description = "CIDRs permitidos para acesso ao ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
  default     = ""
}

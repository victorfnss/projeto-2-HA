variable "vpc_id" {
  description = "ID da VPC onde os security groups serão criados"
  type        = string
}

variable "name_prefix" {
  description = "Prefixo para os nomes dos security groups"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Porta da aplicação"
  type        = number
  default     = 8080
}

variable "alb_sg_id" {
  description = "ID do security group do ALB"
  type        = string
}

variable "alb_cidr_blocks" {
  description = "CIDR blocks permitidos para o ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "private_cidr_block" {
  description = "CIDR block da rede privada"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

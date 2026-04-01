variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
}

variable "public_subnet_id" {
  description = "ID da subnet pública onde a NAT será criada"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o ASG"
  type        = list(string)
}

variable "app_sg_id" {
  description = "ID do security group da aplicação"
  type        = string
}

variable "nat_sg_id" {
  description = "ID do security group da NAT"
  type        = string
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = ""
}

variable "nat_instance_type" {
  description = "Tipo da instância NAT"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "Tipo das instâncias da aplicação"
  type        = string
  default     = "t3.micro"
}

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
  description = "Período de graça para health check"
  type        = number
  default     = 300
}

variable "user_data_path" {
  description = "Caminho para o script user_data da NAT"
  type        = string
  default     = "./user_data/nat_instance.sh"
}

variable "app_user_data_path" {
  description = "Caminho para o script user_data da aplicação"
  type        = string
  default     = "./user_data/script_inicial.sh"
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

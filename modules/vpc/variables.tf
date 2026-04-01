variable "cidr_block" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "Mapa de subnets com configuração de AZ e tipo"
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

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC projeto 2"
  type        = string
  default     = "vpc-projeto-ha-alb"
}

variable "private_key_path" {
  default = "~/.ssh/projeto-aws-key"
}
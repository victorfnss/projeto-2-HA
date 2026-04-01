# Security Group das Instâncias (Privado)
resource "aws_security_group" "app_sg" {
  name        = "${var.name_prefix}-app-sg"
  description = "Permite trafego APENAS do Load Balancer"
  vpc_id      = var.vpc_id

  # Ingress restrito ao SG do ALB
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-sg"
  })
}

# Security Group do Load Balancer (Público)
resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Permite HTTP vindo da Internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

# Security Group para a NAT Instance
resource "aws_security_group" "nat_sg" {
  name   = "${var.name_prefix}-nat-sg"
  vpc_id = var.vpc_id

  # Permite tráfego vindo da rede privada
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-sg"
  })
}

# Outputs
output "app_sg_id" {
  description = "ID do security group da aplicação"
  value       = aws_security_group.app_sg.id
}

output "alb_sg_id" {
  description = "ID do security group do ALB"
  value       = aws_security_group.alb_sg.id
}

output "nat_sg_id" {
  description = "ID do security group da NAT"
  value       = aws_security_group.nat_sg.id
}

output "app_sg_arn" {
  description = "ARN do security group da aplicação"
  value       = aws_security_group.app_sg.arn
}

output "alb_sg_arn" {
  description = "ARN do security group do ALB"
  value       = aws_security_group.alb_sg.arn
}

output "nat_sg_arn" {
  description = "ARN do security group da NAT"
  value       = aws_security_group.nat_sg.arn
}

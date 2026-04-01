# Módulo Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security Group do Load Balancer - permite HTTP vindo da Internet"
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

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_lb" "app_alb" {
  name               = "${var.name_prefix}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name_prefix}-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
    port                = var.app_port
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Outputs
output "alb_dns_name" {
  description = "DNS do Load Balancer para acessar a aplicação"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "ARN do Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.app_tg.arn
}

output "alb_sg_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb_sg.id
}

output "alb_sg_arn" {
  description = "ARN do Security Group do ALB"
  value       = aws_security_group.alb_sg.arn
}

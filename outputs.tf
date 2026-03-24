output "alb_dns_name" {
  description = "DNS do Load Balancer para acessar a aplicação"
  value       = aws_lb.app_alb.dns_name
}

output "asg_name" {
  description = "Nome do Auto Scaling Group para monitoramento"
  value       = aws_autoscaling_group.app_asg.name
}
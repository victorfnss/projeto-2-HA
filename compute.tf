data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.minha_chave.key_name

  user_data = base64encode(file("./user_data/script_inicial.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App-Server-ASG"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {

  vpc_zone_identifier = [for s in aws_subnet.public : s.id]
  
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  # Isso avisa o ASG para esperar o Load Balancer dizer se a máquina está OK
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

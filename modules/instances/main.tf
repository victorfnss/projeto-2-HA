# Dados da AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

# Instance Profile IAM
resource "aws_iam_role" "ssm_role" {
  name = "${var.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-ssm-role" })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.nat_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.nat_sg_id]
  source_dest_check      = false

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = file(var.user_data_path)

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-instance"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template da Aplicação
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.name_prefix}-app-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  user_data = base64encode(file(var.app_user_data_path))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-app-server"
    })
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "${var.name_prefix}-app-asg-"
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app-server"
    propagate_at_launch = true
  }
}

# Outputs
output "nat_instance_id" {
  description = "ID da NAT Instance"
  value       = aws_instance.nat.id
}

output "app_asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "app_launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.app_launch_template.id
}

output "ssm_role_arn" {
  description = "ARN do IAM Role para SSM"
  value       = aws_iam_role.ssm_role.arn
}

resource "aws_ecs_cluster" "cluster" {
  name = "cg-cluster-${var.cgid}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "cg-provider-${var.cgid}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      target_capacity           = 50
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_autoscaling_group" "ecs" {
  name = "cg-asg-${var.cgid}"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.ecs_asg_template.id
  availability_zones = data.aws_availability_zones.available.names

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ecs_asg_template" {
  name          = "cg-ec2-configuration-${var.cgid}"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http.id]
  iam_instance_profile = aws_iam_instance_profile.profile.name

  metadata_options {
    http_tokens = "optional"
    http_endpoint = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
              EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "cg-ec2-role-${var.cgid}"
  role = aws_iam_role.iam_role.name
}

resource "aws_security_group" "allow_http" {
  name        = "cg-group-${var.cgid}"
  description = "Allow inbound traffic on port 80 from your IP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cg_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_ecs_service" "ssrf_web_service" {
  name            = "cg-service-${var.cgid}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn
  launch_type     = "EC2"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "web_task" {
  family                   = "cg-ssrf-web-${var.cgid}"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "cg-ssrf-web-${var.cgid}",
    image = "3iuy/ssrf-php-alpine",
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
    }]
  }])
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
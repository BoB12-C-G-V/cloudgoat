resource "aws_ecs_cluster" "cluster" {
  name = "cg-cluster-${var.cgid}"
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
    aws_ecs_capacity_provider.capacity_provider.name
  ]
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

resource "aws_autoscaling_group" "ecs" {
  name = "cg-asg-${var.cgid}"

  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.all_subnets.ids

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "template" {
  name_prefix   = "cg-launch-template-${var.cgid}"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http.id]
  }

  metadata_options {
    http_tokens = "optional"
  }

  user_data = base64encode(
    <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config;
EOF
  )
}

resource "aws_iam_instance_profile" "profile" {
  name = "cg-ec2-role-${var.cgid}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "allow_http" {
  name        = "cg-group-${var.cgid}"
  description = "Allow inbound traffic on port 80 from whitelist IP"

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
    }],

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
      interval    = 30,
      timeout     = 5,
      retries     = 3,
      startPeriod = 30
    }
  }])
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

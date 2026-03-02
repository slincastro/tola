locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

locals {
  selected_azs       = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
  selected_vpc_id    = var.create_vpc ? aws_vpc.this[0].id : var.existing_vpc_id
  private_subnet_ids = var.create_vpc ? aws_subnet.private[*].id : var.existing_private_subnet_ids
  public_subnet_ids  = var.create_vpc ? aws_subnet.public[*].id : var.existing_public_subnet_ids
}

resource "aws_vpc" "this" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = var.create_vpc ? length(local.selected_azs) : 0
  vpc_id                  = aws_vpc.this[0].id
  availability_zone       = local.selected_azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = var.create_vpc ? length(local.selected_azs) : 0
  vpc_id                  = aws_vpc.this[0].id
  availability_zone       = local.selected_azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-private-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count = var.create_vpc ? 1 : 0
  vpc   = true

  tags = {
    Name = "${local.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.create_vpc ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${local.name_prefix}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.create_vpc ? length(aws_subnet.public) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.create_vpc ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Example app security group allowed to talk to MongoDB"
  vpc_id      = local.selected_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

resource "aws_security_group_rule" "app_ingress" {
  count             = length(var.app_allowed_cidrs)
  type              = "ingress"
  security_group_id = aws_security_group.app.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.app_allowed_cidrs[count.index]]
}

resource "aws_security_group" "mongo" {
  name        = "${local.name_prefix}-mongo-sg"
  description = "MongoDB SG for ECS EC2 host"
  vpc_id      = local.selected_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-mongo-sg"
  }
}

resource "aws_security_group_rule" "mongo_ingress_app" {
  type                     = "ingress"
  from_port                = var.mongo_db_port
  to_port                  = var.mongo_db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongo.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow MongoDB from app SG only"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${local.name_prefix}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${local.name_prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "mongo" {
  name              = "/ecs/${local.name_prefix}-mongo"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_cluster" "mongo" {
  name = "${local.name_prefix}-mongo-cluster"
}

resource "aws_launch_template" "mongo" {
  name_prefix   = "${local.name_prefix}-mongo-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  vpc_security_group_ids = [aws_security_group.mongo.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdb"

    ebs {
      volume_size           = var.mongo_ebs_size_gb
      volume_type           = "gp3"
      iops                  = var.mongo_ebs_iops
      throughput            = var.mongo_ebs_throughput
      encrypted             = true
      delete_on_termination = false
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    ecs_cluster_name = aws_ecs_cluster.mongo.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-mongo-ecs"
    }
  }
}

resource "aws_autoscaling_group" "mongo" {
  name                = "${local.name_prefix}-mongo-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_capacity
  max_size            = var.max_capacity
  vpc_zone_identifier = local.private_subnet_ids
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.mongo.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-mongo-ecs"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "mongo" {
  name = "${local.name_prefix}-mongo-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.mongo.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "mongo" {
  cluster_name       = aws_ecs_cluster.mongo.name
  capacity_providers = [aws_ecs_capacity_provider.mongo.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.mongo.name
    weight            = 1
    base              = 1
  }
}

resource "aws_ecs_task_definition" "mongo" {
  family                   = "${local.name_prefix}-mongo"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name              = "mongo"
      image             = "mongo:7"
      essential         = true
      memoryReservation = 512
      memory            = 1024
      portMappings = [
        {
          containerPort = var.mongo_db_port
          hostPort      = var.mongo_db_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "MONGO_INITDB_ROOT_USERNAME"
          value = var.mongo_root_username
        },
        {
          name  = "MONGO_INITDB_ROOT_PASSWORD"
          value = var.mongo_root_password
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "mongo-data"
          containerPath = "/data/db"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mongo.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "mongo"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "mongosh --quiet --eval 'db.adminCommand({ ping: 1 })' || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
    }
  ])

  volume {
    name      = "mongo-data"
    host_path = "/var/lib/mongo"
  }
}

resource "aws_ecs_service" "mongo" {
  name            = "${local.name_prefix}-mongo-service"
  cluster         = aws_ecs_cluster.mongo.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  depends_on = [aws_ecs_cluster_capacity_providers.mongo]
}

data "aws_instances" "mongo_ec2" {
  instance_state_names = ["running"]

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.mongo.name]
  }
}

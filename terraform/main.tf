provider "aws" {
  region = "us-east-1"
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# Define IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach policies to ECS Execution Role (example policies)
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_ecr" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Define ECS Cluster
resource "aws_ecs_cluster" "medical_system_cluster" {
  name = "medicaldepartureblogsystem-cluster"
}

# Define ECS Task Definition
resource "aws_ecs_task_definition" "medical_system_task" {
  family                   = "medicaldepartureblogsystem-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn  # Reference the execution role ARN

  container_definitions = jsonencode([
    {
      name      = "medicaldepartureblogsystem-container"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/medicaldepartureblogsystem-app:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "JWT_SECRET"
          value = "some_jwt_secret"
        },
        {
          name  = "DB_HOST"
          value = "mysql"
        },
        {
          name  = "DB_USER"
          value = "root"
        },
        {
          name  = "DB_PASSWORD"
          value = "root123"
        },
        {
          name  = "DB_NAME"
          value = "medical_db"
        }
      ]
    }
  ])
}

# Define ECS Service
resource "aws_ecs_service" "medical_system_service" {
  name            = "medicaldepartureblogsystem-service"
  cluster         = aws_ecs_cluster.medical_system_cluster.id
  task_definition = aws_ecs_task_definition.medical_system_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = ["subnet-0e663d4623409f35c"]  # Replace with your subnet IDs
    security_groups = ["sg-07f198e20b7a29385"]     # Replace with your security group IDs
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.medical_system_cluster.name
}

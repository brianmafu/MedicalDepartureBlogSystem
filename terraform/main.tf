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

resource "aws_ecs_cluster" "medical_system_cluster" {
  name = "medicaldepartureblogsystem-cluster"
}

resource "aws_ecs_task_definition" "medical_system_task" {
  family                   = "medicaldepartureblogsystem-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "medicaldepartureblogsystem-container"
      image     = "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/medicaldepartureblogsystem-app:latest"
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

resource "aws_ecs_service" "medical_system_service" {
  name            = "medicaldepartureblogsystem-service"
  cluster         = aws_ecs_cluster.medical_system_cluster.id
  task_definition = aws_ecs_task_definition.medical_system_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = ["subnet-0e663d4623409f35c"]
    security_groups = ["sg-07f198e20b7a29385"]
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.medical_system_cluster.name
}

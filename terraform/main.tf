# Define Terraform backend configuration
terraform {
  backend "s3" {
    bucket = "medical-system-deplyment-production-state-v2"
    region = "us-east-1"
    key    = "medical-system-deployment-production.tfstate"
  }
}

# Define AWS provider configuration
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Define variables
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the domain"
  type        = string
  default     = "medicaldepartureblogsystem.com"
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = "medicaldepartureblogsystem.com"
}

# Define VPC, subnets, and networking resources
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Define ECS execution role and policies
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_ecr" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ecs_cloudwatch_logs_policy"
  description = "Policy for ECS tasks to write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:${var.aws_account_id}:log-group:/ecs/medicaldepartureblogsystem:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_cloudwatch" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

# Define ECS security group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow ECS service inbound traffic on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MySQL inbound traffic on port 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define ECS cluster, task definition, service, and related resources
resource "aws_ecs_cluster" "medical_system_cluster" {
  name = "medicaldepartureblogsystem-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/medicaldepartureblogsystem"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "medical_system_task" {
  family                   = "medicaldepartureblogsystem-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "medicaldepartureblogsystem-container"
    image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/medicaldepartureblogsystem-app:prod"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      { name = "NODE_ENV",  value = "production" },
      { name = "JWT_SECRET",  value = "some_jwt_secret" },
      { name = "DB_HOST",  value = aws_db_instance.mysql.endpoint },
      { name = "DB_USER",  value = aws_db_instance.mysql.username },
      { name = "DB_PASSWORD",  value = aws_db_instance.mysql.password },
      { name = "DB_NAME",  value = "medical_db" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/medicaldepartureblogsystem"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "medical_system_service" {
  name            = "medicaldepartureblogsystem-service"
  cluster         = aws_ecs_cluster.medical_system_cluster.id
  task_definition = aws_ecs_task_definition.medical_system_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.private.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

# Define RDS database subnet group and instance
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.public.id
  ]
}

resource "aws_db_instance" "mysql" {
  identifier             = "medical-db-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.36"
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  username               = "root"
  password               = "rootbrianmafu1234"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  tags = {
    Name = "medical_db"
  }
}

# Define ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  // Ingress and egress rules as per your requirements
  ingress {
    description = "Allow HTTP inbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define ALB
resource "aws_lb" "main" {
  name               = "my-ecs-alb"
  internal           = false  // Set to true if internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id]  // Replace with your subnets
}

# Define API Gateway v2 API, integrations, routes, and Route 53 DNS record
resource "aws_apigatewayv2_api" "medical_system_api" {
  name          = "MedicalDepartureBlogSystemAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id     = aws_apigatewayv2_api.medical_system_api.id
  name       = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "ecs_integration" {
  api_id              = aws_apigatewayv2_api.medical_system_api.id
  integration_type    = "HTTP_PROXY"
  integration_uri     = "http://${aws_lb.main.dns_name}:3000"  // Replace with your ALB DNS name
  integration_method  = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "create_blog_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "POST /blogs"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "get_blogs_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "GET /blogs"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "get_blog_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "GET /blogs/{blogId}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_blog_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "DELETE /blogs/{blogId}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "update_blog_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "PATCH /blogs/{blogId}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "register_user_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "POST /users/register"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "login_user_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "POST /users/login"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "api_docs_route" {
  api_id    = aws_apigatewayv2_api.medical_system_api.id
  route_key = "GET /api-docs"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

# Define Route 53 DNS record for API
resource "aws_route53_record" "api" {
  zone_id = var.hosted_zone_id
  name    = "api.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_apigatewayv2_api.medical_system_api.api_endpoint]
}

# Define output for API URL
output "api_url" {
  value = aws_route53_record.api.fqdn
}

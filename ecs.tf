data "template_file" "devops-hello-python_task_definition" {
  template = file("task-definitions/${var.app_name}-taskdef.json")
  vars = {
    aws_ecr_repository            = aws_ecr_repository.devops-hello-python.repository_url
    tag                           = "latest"
    container_name                = var.app_name
    awslogs_cloudwatch_group_name = aws_cloudwatch_log_group.devops-hello-python.name
    region                        = var.default_region
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_execution_role_arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.devops-hello-python_task_definition.rendered
  tags = {    
    Application = var.app_name
  }

}

resource "aws_ecs_service" "service" {
  name                               = "${var.app_name}-service"
  cluster                            = aws_ecs_cluster.service.id
  task_definition                    = aws_ecs_task_definition.service.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 100
  launch_type                        = "FARGATE"

  

  network_configuration {
    security_groups  = [aws_security_group.service_access.id]
    subnets          = var.private_subnets.*
    assign_public_ip = true
  }
  //Assign the Load Balancer to use on this service, specifing the TargetGroup with the container and port it opens
  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.app_name
    container_port   = 8000
  }

  //The Service requires to have a forard in teh load balancer and task execution policy to download the image
  depends_on = [aws_lb_listener.https_forward]

  tags = {    
    Application = var.app_name
  }
}

resource "aws_ecs_cluster" "service" {
  name = "${var.app_name}-cluster"
}

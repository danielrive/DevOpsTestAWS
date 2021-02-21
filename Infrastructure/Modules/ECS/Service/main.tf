# terraform code to create an AWS ECS service


resource "aws_ecs_service" "ECS_SERVICE" {
  name                              = "Service-${var.NAME}"
  cluster                           = var.ECS_CLUSTER_ID
  task_definition                   = var.ARN_TASK_DEFINITION
  desired_count                     = var.DESIRED_TASKS
  health_check_grace_period_seconds = 10
  launch_type                       = "FARGATE"
  network_configuration {
    security_groups = [var.ARN_SECURITY_GROUP]
    subnets         = [var.SUBNET_ID[0], var.SUBNET_ID[1]]
  }
  load_balancer {
    target_group_arn = var.ARN_TARGET_GROUP
    container_name   = "Container-${var.NAME}"
    container_port   = var.CONTAINER_PORT
  }
}

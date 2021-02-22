# terraform code to create a task definition that use secret manager 

resource "aws_ecs_task_definition" "ECS_TASK_DEFINITION" {
  family                   = "task-definition-${var.NAME}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.CPU
  memory                   = var.MEMORY
  execution_role_arn       = var.ARN_ROLE
  container_definitions    = <<DEFINITION
            [
              {
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "secretOptions": null,
                    "options": {
                      "awslogs-group": "/ecs/TaskDF-${var.NAME}",
                      "awslogs-region": "${var.REGION}",
                      "awslogs-stream-prefix": "ecs"
                    }
                  },
                "cpu": 0,
                "image": "${var.DOCKER_REPO}",
                "name": "Container-${var.NAME}",
                "networkMode": "awsvpc",
                "portMappings": [
                  {
                    "containerPort": ${var.CONTAINER_PORT},
                    "hostPort": ${var.CONTAINER_PORT}
                  }
                ],
                "secrets": [
                  {
                    "name" : "secrets",
                    "valueFrom" :  "${var.SECRET_ARN}"
                  }
                ]
                }
            ]
            DEFINITION
}


# CloudWatch Logs groups to store ecs-containers logs
resource "aws_cloudwatch_log_group" "TaskDF-Log_Group" {
  name              = "/ecs/TaskDF-${var.NAME}"
  retention_in_days = 30
}

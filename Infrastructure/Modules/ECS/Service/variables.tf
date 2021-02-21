## Variables ECS Task

variable "NAME" {
  description = "A name for the ecs service"
  type        = string
}

variable "DESIRED_TASKS" {
  description = "The minumum number of tasks to run in the service"
  type        = string
}

variable "REGION" {
  description = "Region in which the resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "ARN_SECURITY_GROUP" {
  description = "ARN of the security group for the tasks"
  type        = string
}

variable "ECS_CLUSTER_ID" {
  description = "The ECS cluster ID in which the resources will be created"
  type        = string
}

variable "ARN_TARGET_GROUP" {
  description = "the ARN of the AWS Target Group to put the ECS task"
  type        = string
}

variable "ARN_TASK_DEFINITION" {
  description = "The ARN of the Task Definition to use to deploy the tasks"
  type        = string
}

variable "SUBNET_ID" {
  description = "Subnet ID in which ecs will deploy the tasks"
  type        = list(string)
}

variable "CONTAINER_PORT" {
  description = "the port that the container will listen request"
  type        = string
}

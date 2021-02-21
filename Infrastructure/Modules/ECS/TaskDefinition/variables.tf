variable "NAME" {
  description = " A name for Task Definition"
  type        = string
}

variable "ARN_ROLE" {
  description = "the IAM ARN role that ecs task will use to call antoher services in AWS"
  type        = string
}
variable "CPU" {
  description = "the CPU value to assign to container, read AWS documentation to available values"
  type        = string
}

variable "MEMORY" {
  description = "the MEMORY value to assign to container, read AWS documentation to available values"
  type        = string
}

variable "DOCKER_REPO" {
  description = "The docker registry url in which ecs will get the Docker image"
  type        = string
}

variable "REGION" {
  description = "Region in which the resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "SECRET_ARN" {
  description = "The ARN of the secret manager created and that ECS will use to set environment variables"
  type        = string

}

variable "CONTAINER_PORT" {
  description = "the port that the container will listen request"
  type        = string
}

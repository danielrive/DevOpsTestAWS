variable "NAME" {
  description = "a name for target group or alb"
  type        = string
}

variable "TARGET_GROUP" {
  description = "the arn of the target group created "
  type        = string
  default     = ""
}

variable "CREATE_ALB" {
  description = "set to true this variable to create an ALB"
  type        = bool
  default     = false
}

variable "ENABLE_HTTPS" {
  description = "set to true this variable to create a HTTPS listener"
  type        = bool
  default     = false
}

variable "CREATE_TARGET_GROUP" {
  description = "set to true this variable to create a Target Group"
  type        = bool
  default     = false
}

variable "SUBNETS" {
  description = "subnets id for ALB"
  type        = list
  default     = []
}

variable "SECURITY_GROUP" {
  description = "Security group id for the ALB"
  type        = string
  default     = ""
}

variable "PORT" {
  description = "the port that the targer group will use"
  type        = number
  default     = 80
}

variable "PROTOCOL" {
  description = "Protocol that the target group will use"
  type        = string
  default     = ""
}

variable "VPC" {
  description = "VPC id for Target Group"
  type        = string
  default     = ""
}

variable "TG_TYPE" {
  description = "Target Group Type (instance,ip,lambda)"
  type        = string
  default     = ""
}

variable "HEALTH_CHECK_PATH" {
  description = "the Path in which the alb will send health checks "
  type        = string
  default     = ""
}

variable "HEALTH_CHECK_PORT" {
  description = "the Port in which the alb will send health checks"
  type        = number
  default     = 80
}

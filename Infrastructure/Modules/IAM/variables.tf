variable "NAME" {
  description = "A name for the Role"
  type        = string
}

variable "CREATE_ECS_ROLE" {
  description = "set this variable to true if you want to create a role for ECS"
  type        = bool
  default     = false
}


variable "CREATE_DEVOPS_ROLE" {
  description = "set this variable to true if you want to create a role for AWS DevOps Tools"
  type        = bool
  default     = false
}



variable "CREATE_POLICY" {
  description = "set this variable to true if you want to create an IAM Policy"
  type        = bool
  default     = false
}


variable "ATTACH_TO" {
  description = "the arn or role name to attach the policy created"
  type        = string
  default     = ""
}

variable "POLICY" {
  description = "a json with the policy"
  type        = string
  default     = ""
}

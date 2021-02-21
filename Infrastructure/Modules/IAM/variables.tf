variable "NAME" {
  description = "A name for the Role"
  type        = string
}

variable "CREATE_ECS_ROLE" {
  description = "set this variable to true if you want to create a role for ECS"
  type        = bool
  default     = false
}

variable "CREATE_POLICY" {
  ddescription = "set this variable to true if you want to create an IAM Policy"
  type         = bool
  default      = false
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

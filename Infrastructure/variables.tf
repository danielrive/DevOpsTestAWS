# variables main project

variable "AWS_PROFILE" {
  type        = string
  description = "The profile name that you have configured in the file .aws/credentials"
}

variable "AWS_REGION" {
  type        = string
  default     = "us-east-1"
  description = "the Region in which you want to launch the resources"
}

variable "ENVIRONMENT_NAME" {
  type    = string
  default = "us-east-1"

}

variable "GITHUBTOKEN" {
  type    = string
  default = "1234"

}


variable "PORT_APP" {
  default = {
    PORT = "9296"
  }

  type = map(string)
}

#   Providers 

provider "aws" {
  profile = var.AWS_PROFILE
  region  = var.AWS_REGION
}

resource "random_id" "RANDOM_ID" {
  byte_length = "2"
}

# # # Account ID  # # #

data "aws_caller_identity" "ID_CURRENT_ACCOUNT" {}

# # # Certificate ARN  # # #

data "aws_acm_certificate" "CERTIFICATE" {
  domain = "danielrive.site"
}


#   Networking 

module "Networking" {
  source = "./Modules/Networking"
  CIDR   = ["10.100.0.0/16"]
  NAME   = var.ENVIRONMENT_NAME
}

# ECS Role 

module "ECS_ROLE" {
  source          = "./Modules/IAM"
  CREATE_ECS_ROLE = true
  NAME            = "ECS-Role-TASK"
}


data "aws_iam_policy_document" "KMS_POLICY" {
  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.ECS_ROLE.ARN_ROLE]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.ID_CURRENT_ACCOUNT.account_id}:root"]
    }
    actions = [
      "*"
    ]
    resources = ["*"]

  }
}

# Creating KMS Key

module "KMS_SECRET_MANAGER" {
  source = "./Modules/KMS"
  NAME   = "KMS-key-SecretManager"
  providers = {
    aws = aws.Security_Account
  }
  POLICY = data.aws_iam_policy_document.KMS_POLICY.json
}


data "aws_iam_policy_document" "ROLE_POLICY" {
  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [module.KMS_SECRET_MANAGER.ARN_KMS]
  }
}


module "POLICY_ECS_ROLE" {
  source        = "./Modules/IAM"
  NAME          = "ECS-Role-TASK"
  CREATE_POLICY = true
  ATTACH_TO     = module.ECS_ROLE.NAME_ROLE
  POLICY        = data.aws_iam_policy_document.ROLE_POLICY.json

}

data "aws_iam_policy_document" "SECRET_MANAGER_POLICY" {
  statement {
    sid    = "AllowUseSecrerManager"
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    principals {
      type        = "AWS"
      identifiers = [module.ECS_ROLE.ARN_ROLE]
    }
    resources = ["*"]
  }
}


module "SECRET_MANAGER" {
  source    = "./Modules/SecretManager"
  NAME      = "SECRET_MANAGER_TEST1"
  RETENTION = 10
  KMS_KEY   = module.KMS_SECRET_MANAGER.ARN_KMS
  POLICY    = data.aws_iam_policy_document.SECRET_MANAGER_POLICY.json

}

module "ECS_TASK_DEFINITION" {
  depends_on     = [module.SECRET_MANAGER]
  source         = "./Modules/ECS/TaskDefinition"
  NAME           = "test"
  ARN_ROLE       = module.ECS_ROLE.ARN_ROLE
  CPU            = 512
  MEMORY         = "1024"
  DOCKER_REPO    = "golang:1.16"
  REGION         = "us-east-1"
  SECRET_ARN     = module.SECRET_MANAGER.SECRET_ARN
  CONTAINER_PORT = 80
}

module "TARGET_GROUP" {
  source              = "./Modules/ALB"
  CREATE_TARGET_GROUP = true
  NAME                = "testing"
  PORT                = 80
  PROTOCOL            = "HTTP"
  VPC                 = module.Networking.AWS_VPC
  TG_TYPE             = "ip"
  HEALTH_CHECK_PATH   = "/"
  HEALTH_CHECK_PORT   = 80
}

resource "aws_security_group" "SECURITY_GROUP_ALB" {
  name        = "SG_ALB_TEST"
  description = "controls access to the ALB"
  vpc_id      = module.Networking.AWS_VPC
  tags = {
    Name = "SG_ALB_TEST"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "ALB" {
  source         = "./Modules/ALB"
  CREATE_ALB     = true
  NAME           = "alb-testing"
  SUBNETS        = [module.Networking.PUBLIC_SUBNETS[0], module.Networking.PUBLIC_SUBNETS[1]]
  SECURITY_GROUP = aws_security_group.SECURITY_GROUP_ALB.id
  TARGET_GROUP   = module.TARGET_GROUP.ARN_TG

}

resource "aws_security_group" "SECURITY_GROUP_ECS_TASK" {
  name        = "SG_ECS_TASK"
  description = "controls access to the ECS task"
  vpc_id      = module.Networking.AWS_VPC
  tags = {
    Name = "SG_ECS_TASK"
  }

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.SECURITY_GROUP_ALB.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "CLUSTER" {
  name = "Cluster-testing"
}

module "ECS_SERVICE" {
  depends_on          = [module.ALB]
  source              = "./Modules/ECS/Service"
  NAME                = "test"
  DESIRED_TASKS       = 1
  REGION              = "us-east-1"
  ARN_SECURITY_GROUP  = aws_security_group.SECURITY_GROUP_ECS_TASK.id
  ECS_CLUSTER_ID      = aws_ecs_cluster.CLUSTER.id
  ARN_TARGET_GROUP    = module.TARGET_GROUP.ARN_TG
  ARN_TASK_DEFINITION = module.ECS_TASK_DEFINITION.ARN_TASK_DEFINITION
  SUBNET_ID           = [module.Networking.PRIVATE_SUBNETS[0], module.Networking.PRIVATE_SUBNETS[1]]
  CONTAINER_PORT      = 80
}






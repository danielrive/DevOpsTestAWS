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

# data "aws_acm_certificate" "CERTIFICATE" {
#   domain = "danielrive.site"
# }


#   Networking 

module "Networking" {
  source = "./Modules/Networking"
  CIDR   = ["10.120.0.0/16"]
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
  NAME   = "KMS-key-SecretManager-${var.ENVIRONMENT_NAME}"
  POLICY = data.aws_iam_policy_document.KMS_POLICY.json
}



resource "aws_ecr_repository" "AWS_ECR" {
  name                 = "repo-${var.ENVIRONMENT_NAME}"
  image_tag_mutability = "MUTABLE"
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
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "ECR:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [module.KMS_SECRET_MANAGER.ARN_KMS]
  }
}


module "POLICY_ECS_ROLE" {
  source        = "./Modules/IAM"
  NAME          = "ECS-Role-TASK-${var.ENVIRONMENT_NAME}"
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
  NAME      = "SECRET_MANAGER_${var.ENVIRONMENT_NAME}"
  RETENTION = 10
  KMS_KEY   = module.KMS_SECRET_MANAGER.ARN_KMS
  POLICY    = data.aws_iam_policy_document.SECRET_MANAGER_POLICY.json

}


module "ECS_TASK_DEFINITION" {
  depends_on     = [module.SECRET_MANAGER, aws_ecr_repository.AWS_ECR]
  source         = "./Modules/ECS/TaskDefinition"
  NAME           = "TD-${var.ENVIRONMENT_NAME}"
  ARN_ROLE       = module.ECS_ROLE.ARN_ROLE
  CPU            = 512
  MEMORY         = "1024"
  DOCKER_REPO    = aws_ecr_repository.AWS_ECR.repository_url
  REGION         = "us-east-1"
  SECRET_ARN     = module.SECRET_MANAGER.SECRET_ARN
  CONTAINER_PORT = 80
}

module "TARGET_GROUP" {
  source              = "./Modules/ALB"
  CREATE_TARGET_GROUP = true
  NAME                = "TG-${var.ENVIRONMENT_NAME}"
  PORT                = 80
  PROTOCOL            = "HTTP"
  VPC                 = module.Networking.AWS_VPC
  TG_TYPE             = "ip"
  HEALTH_CHECK_PATH   = "/"
  HEALTH_CHECK_PORT   = 80
}

resource "aws_security_group" "SECURITY_GROUP_ALB" {
  name        = "SG_ALB_${var.ENVIRONMENT_NAME}"
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
  NAME           = "alb-${var.ENVIRONMENT_NAME}"
  SUBNETS        = [module.Networking.PUBLIC_SUBNETS[0], module.Networking.PUBLIC_SUBNETS[1]]
  SECURITY_GROUP = aws_security_group.SECURITY_GROUP_ALB.id
  TARGET_GROUP   = module.TARGET_GROUP.ARN_TG

}

# resource "aws_security_group" "SECURITY_GROUP_ECS_TASK" {
#   name        = "SG_ECS_TASK_${var.ENVIRONMENT_NAME}"
#   description = "controls access to the ECS task"
#   vpc_id      = module.Networking.AWS_VPC
#   tags = {
#     Name = "SG_ECS_TASK_${var.ENVIRONMENT_NAME}"
#   }

#   ingress {
#     protocol        = "tcp"
#     from_port       = "80"
#     to_port         = "80"
#     security_groups = [aws_security_group.SECURITY_GROUP_ALB.id]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_ecs_cluster" "CLUSTER" {
#   name = "Cluster-testing"
# }

# module "ECS_SERVICE" {
#   depends_on          = [module.ALB]
#   source              = "./Modules/ECS/Service"
#   NAME                = "Service_${var.ENVIRONMENT_NAME}"
#   DESIRED_TASKS       = 1
#   REGION              = var.AWS_REGION
#   ARN_SECURITY_GROUP  = aws_security_group.SECURITY_GROUP_ECS_TASK.id
#   ECS_CLUSTER_ID      = aws_ecs_cluster.CLUSTER.id
#   ARN_TARGET_GROUP    = module.TARGET_GROUP.ARN_TG
#   ARN_TASK_DEFINITION = module.ECS_TASK_DEFINITION.ARN_TASK_DEFINITION
#   SUBNET_ID           = [module.Networking.PRIVATE_SUBNETS[0], module.Networking.PRIVATE_SUBNETS[1]]
#   CONTAINER_PORT      = 80
# }


## CodePipeline

resource "aws_s3_bucket" "AWS_BUCKET" {
  bucket = "artifacts-codepipeline-${var.ENVIRONMENT_NAME}"
  acl    = "private"
  tags = {
    Name        = "artifacts-codepipeline-${var.ENVIRONMENT_NAME}"
    Environment = "Dev"
  }
}

module "DevOps_ROLE" {
  source             = "./Modules/IAM"
  CREATE_DEVOPS_ROLE = true
  NAME               = var.ENVIRONMENT_NAME
}


data "aws_iam_policy_document" "ROLE_POLICY_DEVOPS_ROLE" {
  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCodebuildActions"
    effect = "Allow"
    actions = [
      "codebuild:*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"

    ]
    resources = [aws_ecr_repository.AWS_ECR.arn]
  }
  statement {
    sid    = "AllowCloudWatchActions"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

module "POLICY_DEVOPS_ROLE" {
  source        = "./Modules/IAM"
  NAME          = "devops-${var.ENVIRONMENT_NAME}"
  CREATE_POLICY = true
  ATTACH_TO     = module.DevOps_ROLE.NAME_ROLE
  POLICY        = data.aws_iam_policy_document.ROLE_POLICY_DEVOPS_ROLE.json

}

module "CODEBUILD" {
  source       = "./Modules/CodeBuild"
  NAME         = "codebuild-${var.ENVIRONMENT_NAME}"
  IAM_ROLE     = module.DevOps_ROLE.ARN_ROLE
  REGION       = var.AWS_REGION
  ACCOUNT_ID   = data.aws_caller_identity.ID_CURRENT_ACCOUNT.account_id
  ECR_REPO_URL = aws_ecr_repository.AWS_ECR.repository_url

}


module "CODEPIPELINE" {
  source            = "./Modules/CodePipeline"
  NAME              = "pipe-${var.ENVIRONMENT_NAME}"
  PIPE_ROLE         = module.DevOps_ROLE.ARN_ROLE
  S3_BUCKET         = aws_s3_bucket.AWS_BUCKET.id
  GITHUB_TOKEN      = "b5d08cf48160b1d28d68e8e3031411b9b6f47402"
  REPO_OWNER        = "danielrive"
  REPO_NAME         = "DevOpsTestAWS"
  BRANCH            = "develop"
  CODEBUILD_PROJECT = module.CODEBUILD.ID
  ecs_cluster_name  = "sasd"
  service_name      = "asdas"

}














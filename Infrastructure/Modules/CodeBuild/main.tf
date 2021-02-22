resource "aws_codebuild_project" "AWS_CODEBUILD" {
  name          = var.NAME
  description   = "Terraform codebuild project"
  build_timeout = "10"
  service_role  = var.IAM_ROLE

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "docker:dind"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_REGION"
      value = var.REGION
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.ACCOUNT_ID
    }
    environment_variable {
      name  = "REPO_URL"
      value = var.ECR_REPO_URL
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }


  source {
    type      = "CODEPIPELINE"
    buildspec = "./Infrastructure/buildspec.yml"
  }
  tags = {
    CreatedBy = "Terraform"
  }
}

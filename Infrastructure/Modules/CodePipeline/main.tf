resource "aws_codepipeline" "AWS_CODEPIPELINE" {
  name     = var.NAME
  role_arn = var.PIPE_ROLE

  artifact_store {
    location = var.S3_BUCKET
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        OAuthToken           = var.GITHUB_TOKEN
        Owner                = var.REPO_OWNER
        Repo                 = var.REPO_NAME
        Branch               = var.BRANCH
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ProjectName = var.CODEBUILD_PROJECT
      }
    }
  }

  #   stage {
  #     name = "Deploy"

  #     action {
  #       name            = "Deploy"
  #       category        = "Deploy"
  #       owner           = "AWS"
  #       provider        = "ECS"
  #       input_artifacts = ["task"]
  #       version         = "1"

  #       configuration = {
  #         ClusterName = var.ecs_cluster_name
  #         ServiceName = var.service_name
  #       }
  #     }
  #   }

  lifecycle {
    # prevent github OAuthToken from causing updates, since it's removed from state file
    ignore_changes = [stage[0].action[0].configuration]
  }
}

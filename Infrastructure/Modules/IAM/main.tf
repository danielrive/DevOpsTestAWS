# Terraform Module to create IAM Roles and Policies

#  Role Creation
# For ECS
resource "aws_iam_role" "ECS_ROLE" {
  count              = var.CREATE_ECS_ROLE == true ? 1 : 0
  name               = "ECS-ROLE-${var.NAME}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = "ECS-ROLE-${var.NAME}"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "DevOps_ROLE" {
  count              = var.CREATE_DEVOPS_ROLE == true ? 1 : 0
  name               = "ECS-ROLE-${var.NAME}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com",
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "POLICY_FOR_ROLE" {
  count       = var.CREATE_POLICY == true ? 1 : 0
  name        = "Policy_${var.NAME}"
  description = "policy for Role ${var.NAME}"
  lifecycle {
    create_before_destroy = true
  }
  policy = var.POLICY
}


resource "aws_iam_role_policy_attachment" "ATTACHEMENT" {
  count      = var.CREATE_POLICY == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = var.ATTACH_TO
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ATTACHEMENT2" {
  count      = var.CREATE_POLICY == true ? 1 : 0
  policy_arn = aws_iam_policy.POLICY_FOR_ROLE[0].arn
  role       = var.ATTACH_TO
  lifecycle {
    create_before_destroy = true
  }
}

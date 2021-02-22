
output "ARN_ROLE" {
  value = (var.CREATE_ECS_ROLE == true
    ? (length(aws_iam_role.ECS_ROLE) > 0 ? aws_iam_role.ECS_ROLE[0].arn : "")
  : (length(aws_iam_role.DevOps_ROLE) > 0 ? aws_iam_role.DevOps_ROLE[0].arn : ""))
}

output "NAME_ROLE" {
  value = (var.CREATE_ECS_ROLE == true
    ? (length(aws_iam_role.ECS_ROLE) > 0 ? aws_iam_role.ECS_ROLE[0].name : "")
  : (length(aws_iam_role.DevOps_ROLE) > 0 ? aws_iam_role.DevOps_ROLE[0].arn : ""))
}

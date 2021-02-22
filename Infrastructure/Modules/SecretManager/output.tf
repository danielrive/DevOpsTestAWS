output "SECRET_ARN" {
  value = aws_secretsmanager_secret.SECRETMANAGER.arn
}


output "SECRET_ID" {
  value = aws_secretsmanager_secret.SECRETMANAGER.id
}

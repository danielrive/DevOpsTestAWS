# Outputs VPC Modules 

# VPC ID 
output "AWS_VPC" {
  value = aws_vpc.AWS_VPC.id
}

# ------ Subnets Publics ------
output "PUBLIC_SUBNETS" {
  value = [aws_subnet.PUBLIC_SUBNETS[0].id, aws_subnet.PUBLIC_SUBNETS[1].id]
}

# ------ Subnets Private ------
output "PRIVATE_SUBNETS" {
  value = [aws_subnet.PRIVATE_SUBNETS[0].id, aws_subnet.PRIVATE_SUBNETS[1].id]
}

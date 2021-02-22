# A terraform Module To Create VPC, subnets, etc
# to support HA and private and public subnets 



# VPC Creation

resource "aws_vpc" "AWS_VPC" {
  cidr_block           = var.CIDR[0]
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name       = "VPC_${var.NAME}"
    Created_by = "Terraform"
  }
}

# Get Region Available Zones

data "aws_availability_zones" "AZ_AVAILABLES" {
  state = "available"
}

# Subnets Creation

# Public Subnets

resource "aws_subnet" "PUBLIC_SUBNETS" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.AZ_AVAILABLES.names[count.index]
  vpc_id                  = aws_vpc.AWS_VPC.id
  cidr_block              = cidrsubnet(aws_vpc.AWS_VPC.cidr_block, 7, count.index + 1)
  map_public_ip_on_launch = true
  tags = {
    Name       = "PUBLIC_SUBNET_${count.index}_${var.NAME}"
    Created_by = "Terraform"
  }
}
# Private Subnets 

resource "aws_subnet" "PRIVATE_SUBNETS" {
  count             = 2
  availability_zone = data.aws_availability_zones.AZ_AVAILABLES.names[count.index]
  vpc_id            = aws_vpc.AWS_VPC.id
  cidr_block        = cidrsubnet(aws_vpc.AWS_VPC.cidr_block, 7, count.index + 3)
  tags = {
    Name       = "PRIVATE_SUBNET_${count.index}_${var.NAME}"
    Created_by = "Terraform"
  }
}

# Internet Gateway 

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.AWS_VPC.id
  tags = {
    Name       = "IGW_${var.NAME}"
    Created_by = "Terraform"
  }
}

# Create Default Route Public Table 

resource "aws_default_route_table" "RT_PUBLIC" {
  default_route_table_id = aws_vpc.AWS_VPC.default_route_table_id

  ### Internet Route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name       = "PUBLIC_RT_${var.NAME}"
    Created_by = "Terraform"
  }
}

# Create EIP
resource "aws_eip" "EIP" {
  vpc = true
  tags = {
    Name       = "EIP-${var.NAME}"
    Created_by = "Terraform"
  }
}

# Attach EIP to Nat Gateway  
resource "aws_nat_gateway" "NATGW" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.PUBLIC_SUBNETS[0].id
  tags = {
    Name       = "NAT_${var.NAME}"
    Created_by = "Terraform"
  }
}

# Create Private Route Private Table  
resource "aws_route_table" "RT_PRIVATE" {
  vpc_id = aws_vpc.AWS_VPC.id

  ### Internet Route  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGW.id
  }

  tags = {
    Name       = "PRIVATE_RT_${var.NAME}"
    Created_by = "Terraform"
  }
  depends_on = [aws_nat_gateway.NATGW]
}
# Private Subnets Association 
resource "aws_route_table_association" "RT_ASS_PRIV_SUBNETS" {
  count          = 2
  subnet_id      = aws_subnet.PRIVATE_SUBNETS[count.index].id
  route_table_id = aws_route_table.RT_PRIVATE.id
  depends_on     = [aws_route_table.RT_PRIVATE]
}

#------- Public Subnets Association -------
resource "aws_route_table_association" "RT_ASS_PUB_SUBNETs" {
  count          = 2
  subnet_id      = aws_subnet.PUBLIC_SUBNETS[count.index].id
  route_table_id = aws_vpc.AWS_VPC.main_route_table_id
}


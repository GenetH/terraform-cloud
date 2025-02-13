# Get list of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block                   = var.vpc_cidr
  enable_dns_support           = var.enable_dns_support
  enable_dns_hostnames         = var.enable_dns_support
  
}

# Create public subnets
resource "aws_subnet" "public" {
  count = (var.preferred_number_of_public_subnets != null ? var.preferred_number_of_public_subnets : length(data.aws_availability_zones.available.names))

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
tags = merge(
    var.tags,
    {
      Name = "g-public-Subnet-${count.index + 1}"
    }
  )
}
# Create private subnets
resource "aws_subnet" "private" {
  count = (var.preferred_number_of_private_subnets != null ? var.preferred_number_of_private_subnets : length(data.aws_availability_zones.available.names))

  vpc_id                 = aws_vpc.main.id
  cidr_block             = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  map_public_ip_on_launch = false
 
  availability_zone = element(
  [
    data.aws_availability_zones.available.names[0], # First AZ (e.g., us-east-1a)
    data.aws_availability_zones.available.names[1]  # Second AZ (e.g., us-east-1b)
  ],
  count.index % 2
)


  tags = merge(
    var.tags,
    {
      Name = "g-private-Subnet-${count.index + 1}"
    }
  )
}
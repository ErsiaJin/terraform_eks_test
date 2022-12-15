provider "aws" {
  region = local.region
}

locals {
  name = "dev-ihjin"
  region = "ap-northeast-2"
}

module "vpc" {
  source = "../../1.modules/vpc_subent_route"

  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
  
  vpc_tags = {
    Name = "${local.name}-vpc"
  }
  
  public_subnet_tags = {
    Name = "${local.name}-public-subnet"
  }
  
  public_route_table_tags = {
    Name = "${local.name}-public-route"
  }

  private_subnet_tags = {
    Name = "${local.name}-private-subnet"
  }
  
  private_route_table_tags = {
    Name = "${local.name}-private-route"
  }
  
  igw_tags = {
    Name = "${local.name}-igw"
  }
  
  nat_gateway_tags = {
    Name = "${local.name}-nat"
  }
  
  nat_eip_tags = {
    Name = "${local.name}-nat-eip"
  }
}
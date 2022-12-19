provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../1.modules/vpc_subent_route"

  cidr = "${var.vpc_cidr}"

  azs             = ["${var.region}a", "${var.region}c"]
  private_subnets = ["${var.private_subnet_a_cidr}", "${var.private_subnet_c_cidr}"]
  public_subnets  = ["${var.public_subnet_a_cidr}", "${var.public_subnet_c_cidr}"]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.default_tags
  )
  
  vpc_tags = {
    Name = "${var.symbol_name}-vpc"
  }
  
  public_subnet_tags = {
    Name = "${var.symbol_name}-public-subnet"
  }
  
  public_route_table_tags = {
    Name = "${var.symbol_name}-public-route"
  }

  private_subnet_tags = {
    Name = "${var.symbol_name}-private-subnet"
  }
  
  private_route_table_tags = {
    Name = "${var.symbol_name}-private-route"
  }
  
  igw_tags = {
    Name = "${var.symbol_name}-igw"
  }
  
  nat_gateway_tags = {
    Name = "${var.symbol_name}-nat"
  }
  
  nat_eip_tags = {
    Name = "${var.symbol_name}-nat-eip"
  }
}
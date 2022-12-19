variable "default_tags" {
  description = "The Map of tags"
  default = {
    Project     = "dev-ihjin"
	Owner       = "ihjin"
    Environment = "development"
    Terraform   = "true"
  }
}

variable "symbol_name" {
  description = "The string of project symbol_name"
  type        = string
  default     = "dev-ihjin"
}

variable "region" {
  description = "The string of project region"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "The string of vpc_cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_a_cidr" {
  description = "The string of private_subnet_a_cidr"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_c_cidr" {
  description = "The string of private_subnet_c_cidr"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_a_cidr" {
  description = "The string of public_subnet_a_cidr"
  type        = string
  default     = "10.0.11.0/24"
}

variable "public_subnet_c_cidr" {
  description = "The string of public_subnet_c_cidr"
  type        = string
  default     = "10.0.12.0/24"
}
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

variable "eks_node_ami_type" {
  description = "The name of the ec2 eks_node_ami_type"
  type        = string
  default     = "AL2_x86_64"
}

variable "eks_node_instance_type" {
  description = "The name of the ec2 eks_node_instance_type"
  type        = string
  default     = "t3.micro"
}

variable "eks_node_capacity_type" {
  description = "The name of the ec2 eks_node_capacity_type"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_volume_size" {
  description = "The name of the ec2 eks_node_volume_size"
  type        = number
  default     = 10
}


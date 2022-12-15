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


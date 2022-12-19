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

variable "eks_iam_access_key" {
  description = "The eks iam access key"
  type        = string
}

variable "eks_iam_secret_key" {
  description = "The eks iam secret key"
  type        = string
}

data "aws_ami" "bastion_ami" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

variable "bastion_instance_type" {
  description = "The name of the ec2 bastion_instance_type"
  type        = string
  default     = "t3.micro"
}

# 주의!! Key가 사전에 만들어져 있어야 함
variable "bastion_key_name" {
  description = "The name of the ec2 bastion_key_name"
  type        = string
  default     = "Ersia"
}

variable "bastion_volume_size" {
  description = "The name of the ec2 bastion_volume_size"
  type        = number
  default     = 10
}

variable "ssh_server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 22
}
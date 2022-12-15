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

variable "bastion_security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-my-instance"
}

variable "ssh_server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 22
}
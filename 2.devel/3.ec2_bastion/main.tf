provider "aws" {
  region = local.region
}

data "http" "mypc-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "../1.environment/terraform.tfstate"
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../2.eks/terraform.tfstate"
  }
}

locals {
  name                = "dev-ihjin"
  region              = "ap-northeast-2"
  mypc-external-cidr  = "${chomp(data.http.mypc-external-ip.response_body)}/32"
  public_subnet_id    = "${data.terraform_remote_state.environment.outputs.public_subnets[1]}"
  config_map_aws_auth = "${data.terraform_remote_state.eks.outputs.config_map_aws_auth}"
  kubeconfig          = "${data.terraform_remote_state.eks.outputs.kubeconfig}"
}

resource "aws_security_group" "bastion_security_group" {
  name          = "${local.name}-bastion-ec2-sg"
  vpc_id        = "${data.terraform_remote_state.environment.outputs.vpc_id}"

  ingress {
    from_port   = "${var.ssh_server_port}"
    to_port     = "${var.ssh_server_port}"
    protocol    = "tcp"
    cidr_blocks = ["${local.mypc-external-cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${local.name}-bastion-ec2-sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami                     = "${data.aws_ami.bastion_ami.id}"
  instance_type           = "${var.bastion_instance_type}"
  vpc_security_group_ids  = [aws_security_group.bastion_security_group.id]
  subnet_id               = "${local.public_subnet_id}"
  key_name                = "${var.bastion_key_name}"
  disable_api_termination = false

  user_data = "${templatefile("userdata-eks.tftpl", 
                  {hostname            = "${local.name}-bastion-ec2",
				   config_map_aws_auth = "${local.config_map_aws_auth}",
				   kubeconfig          = "${local.kubeconfig}"
				  })}"
  user_data_replace_on_change = true

  root_block_device {
    volume_size = "${var.bastion_volume_size}"
    volume_type = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${local.name}-bastion-ec2:/root"
    }
  }

  tags = {
    Name = "${local.name}-bastion-ec2"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = "${aws_instance.bastion_ec2.id}"
  vpc      = true
  tags = {
    Name = "${local.name}-bastion-eip"
  }
}
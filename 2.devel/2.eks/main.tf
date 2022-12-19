#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#
provider "aws" {
  region = var.region
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

locals {
  vpc_id             = "${data.terraform_remote_state.environment.outputs.vpc_id}"
  private_subnet_ids = "${data.terraform_remote_state.environment.outputs.private_subnets[*]}"
  bastion_cidr       = "${data.terraform_remote_state.environment.outputs.public_subnets_cidr_blocks[1]}"
}

resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "${var.symbol_name}-eks-cluster-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_iam_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_iam_role_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_iam_role.name
}

resource "aws_security_group" "eks_cluster_security_group" {
  name        = "${var.symbol_name}-eks-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${local.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.symbol_name}-eks-cluster-security-group"
    }
  )
}

resource "aws_security_group_rule" "eks_cluster_security_group_rule" {
  description       = "Allow workstation to communicate with the cluster API Server"
  cidr_blocks       = ["${local.bastion_cidr}"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_security_group.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.symbol_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_iam_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_security_group.id]
    subnet_ids         = "${local.private_subnet_ids[*]}"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_iam_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_iam_role_AmazonEKSVPCResourceController
  ]
  
  tags = merge(
    var.default_tags,
    {
      Name = "${var.symbol_name}-eks-cluster"
    }
  )
}

#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#
resource "aws_iam_role" "eks_node_iam_role" {
  name = "${var.symbol_name}-eks-node-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_node_iam_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_iam_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_iam_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_iam_role_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks_node_iam_role.name
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.symbol_name}-eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_iam_role.arn
  subnet_ids      = "${local.private_subnet_ids[*]}"
  
  ami_type       = "${var.eks_node_ami_type}"
  instance_types = ["${var.eks_node_instance_type}"]
  capacity_type  = "${var.eks_node_capacity_type}"
  disk_size      = "${var.eks_node_volume_size}"

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_iam_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_iam_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_iam_role_AmazonEC2ContainerRegistryReadOnly,
	aws_iam_role_policy_attachment.eks_node_iam_role_AmazonEC2RoleforSSM
  ]
  
  tags = merge(
    var.default_tags,
    {
      Name = "${var.symbol_name}-eks_node_group"
    }
  )
}

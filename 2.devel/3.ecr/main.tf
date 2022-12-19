provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${var.symbol_name}-ecr-repository"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.default_tags,
    {
      Name  = "${var.symbol_name}-ecr-repository"
    }
  )
}
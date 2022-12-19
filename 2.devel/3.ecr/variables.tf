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

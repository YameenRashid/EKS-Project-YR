variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "yr-eks-ecr"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-2"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default = {
    Project     = "EKS-Project"
    Environment = "dev"
    Owner       = "yameen"
    ManagedBy   = "terraform"
    Repository  = "github.com/YameenRashid/EKS-Project-YR"
  }
}
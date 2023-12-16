variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed."
  type        = string
}

variable "security_group_ids" {
  description = "Security Group IDs for Application Load Balancers"
  type = object({
    pub  : list(string),
    pri1 : list(string),
  })
}

variable "subnet_ids" {
  description = "Subnet IDs for Application Load Balancers"
  type = object({
    pub  : list(string),
    pri1 : list(string),
  })
}


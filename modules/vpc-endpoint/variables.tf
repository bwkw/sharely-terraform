variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "pri_route_table_id" {
  description = "The ID of the private route table"
  type        = string  
}

variable "pri1_subnet_ids" {
  description = "List of primary subnet IDs"
  type        = list(string)
}

variable "vpc_endpoint_sg_ids" {
  description = "A map of security group IDs for VPC endpoints"
  type = object({
    ecr_api         = list(string)
    ecr_dkr         = list(string)
    cloudwatch_logs = list(string)
    secrets_manager = list(string)
  })
}

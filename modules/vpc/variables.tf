variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "az" {
  description = "The availability zones for the subnets."
  type = object({
    a = string
    c = string
  })
}

variable "pub_subnets" {
  description = "The public subnets for the VPC."
  type = object({
    a = string
    c = string
  })
}

variable "pri1_subnets" {
  description = "The private subnets for the VPC."
  type = object({
    a = string
    c = string
  })
}

variable "pri2_subnets" {
  description = "The private subnets for the VPC."
  type = object({
    a = string
    c = string
  })
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "az" {
  description = "The availability zones for the subnets."
  type = object({
    a = string
    c = string
  })
}

variable "pri2_subnet_ids" {
  description = "List of primary subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with Aurora"
  type        = list(string)
}

variable "database" {
  description = "Database configuration"
  type = object({
    instance_class = string
    username       = string
    password       = string
  })
  sensitive   = true
}

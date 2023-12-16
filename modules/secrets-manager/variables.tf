variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "database" {
  description = "Database related configurations"
  type = object({
    username = string
    password = string
  })
  sensitive   = true
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "environment" {
  description = "The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'."
  type        = string
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs"
  type        = list(string)
}

variable "oidc_thumbprint" {
  description = "Thumbprint of the OIDC provider"
  type        = string
}

variable "github_actions" {
  description = "Github Actions related configurations"
  type = object({
    repository = string
    branch     = string
  })
}

variable "sts_audience" {
  description = "Audience of the OIDC provider"
  type        = string
}

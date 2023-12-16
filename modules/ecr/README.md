<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | ECR repository ARNs |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | ECR repository URLs |
<!-- END_TF_DOCS -->
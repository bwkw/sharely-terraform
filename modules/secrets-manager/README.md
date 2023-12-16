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
| [aws_secretsmanager_secret.aurora_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.aurora_credentials_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_database"></a> [database](#input\_database) | Database related configurations | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_credentials_secret_arn"></a> [aurora\_credentials\_secret\_arn](#output\_aurora\_credentials\_secret\_arn) | n/a |
<!-- END_TF_DOCS -->

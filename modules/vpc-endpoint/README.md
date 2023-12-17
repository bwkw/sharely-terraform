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
| [aws_vpc_endpoint.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'. | `string` | n/a | yes |
| <a name="input_pri1_subnet_ids"></a> [pri1\_subnet\_ids](#input\_pri1\_subnet\_ids) | List of primary subnet IDs | `list(string)` | n/a | yes |
| <a name="input_pri_route_table_id"></a> [pri\_route\_table\_id](#input\_pri\_route\_table\_id) | The ID of the private route table | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_vpc_endpoint_sg_ids"></a> [vpc\_endpoint\_sg\_ids](#input\_vpc\_endpoint\_sg\_ids) | A map of security group IDs for VPC endpoints | <pre>object({<br>    ecr_api         = list(string)<br>    ecr_dkr         = list(string)<br>    cloudwatch_logs = list(string)<br>    secrets_manager = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_vpc_endpoint_id"></a> [secrets\_manager\_vpc\_endpoint\_id](#output\_secrets\_manager\_vpc\_endpoint\_id) | The ID of the VPC Endpoint for Secrets Manager |
<!-- END_TF_DOCS -->

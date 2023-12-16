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
| [aws_appautoscaling_policy.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_target_group_arns"></a> [alb\_target\_group\_arns](#input\_alb\_target\_group\_arns) | ALB target groups ARNs | <pre>object({<br>    pub = string<br>    pri = string<br>  })</pre> | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Autoscaling related configurations | <pre>object({<br>    cpu_scale_up_target_value = number<br>    scale_out_cooldown        = number<br>    scale_in_cooldown         = number<br>    min_capacity              = number<br>    max_capacity              = number<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where infrastructure is deployed, e.g., 'dev', 'stg', 'prod'. | `string` | n/a | yes |
| <a name="input_images"></a> [images](#input\_images) | Docker image configurations | <pre>object({<br>    url = object({<br>      frontend = string<br>      backend  = string<br>    })<br>    tag = object({<br>      frontend = string<br>      backend  = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_task"></a> [task](#input\_task) | Task related configurations | <pre>object({<br>    desired_count = number<br>    cpu           = string<br>    memory        = string<br>    subnet_ids = object({<br>      frontend = list(string)<br>      backend  = list(string)<br>    })<br>    security_group_ids = object({<br>      frontend = list(string)<br>      backend  = list(string)<br>    })<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the ECS cluster. |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | The ARN of the ECS execution role |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | The ARN of the  ECS task definition |
<!-- END_TF_DOCS -->
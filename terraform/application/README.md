# TERRAFORM DOCS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_prefix"></a> [account\_prefix](#input\_account\_prefix) | The AWS account name prefix. Ex: (shared,na,apac,esports...) | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | The AWS enviroment | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The project name | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | The database subnets ids |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | The public subnets CIDR |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | The private subnets ids |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | The private subnets CIDRs |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | The public subnets ids |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | The public subnets CIDR |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The Vpc ID |
| <a name="output_zones"></a> [zones](#output\_zones) | Availability Zones |
<!-- END_TF_DOCS -->

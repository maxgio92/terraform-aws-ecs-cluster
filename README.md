# terraform-aws-ecs-cluster

Terraform module that manages AWS ECS cluster.

This module creates:

- Instance profile
- Autoscaling group
- Elastic IPs (optional)
- Security group

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| default\_tag | The default tag to apply to the resoures | map | `<map>` | no |
| desired\_size | The desired capacity of the autoscaling group | string | n/a | yes |
| efs\_dns\_name | The DNS name of the EFS filesystem to mount on the cluster's instances. | string | `""` | no |
| efs\_mount | Enable to mount an EFS filesystem on the cluster's instances.   If true, please specify the efs_dns_name field. | string | `"false"` | no |
| elastic\_ip\_count | The number of elastic IP to associate to the instances in the autoscaling group | string | `"false"` | no |
| health\_check\_type | 'EC2' or 'ELB'. Controls how checking is done | string | `"EC2"` | no |
| instance\_key\_name | The key name that should be used for the cluster's instances | string | `""` | no |
| instance\_type | The size of instance to launch | string | `"t3.micro"` | no |
| max\_size | The maximum capacity of the autoscaling group | string | n/a | yes |
| min\_size | The minimum capacity of the autoscaling group | string | n/a | yes |
| prefix\_name | The prefix for the name of the resources | string | `"my"` | no |
| protect\_from\_scale\_in | Enable the instance protection setting for the autoscaling group | string | `"false"` | no |
| security\_group\_private\_rules | structure:[{port:   "port number"protocol: "protocol"source: "source security group id"}] | list | `<list>` | no |
| security\_group\_private\_rules\_count | Workaround to:https://github.com/hashicorp/terraform/issues/17421 | string | `"0"` | no |
| security\_group\_public\_rules | structure:[{port:   "port number"protocol: "protocol"source: "CIDR block"}] | list | `<list>` | no |
| security\_group\_public\_rules\_count | Workaround to:https://github.com/hashicorp/terraform/issues/17421 | string | `"0"` | no |
| subnets | A list of subnet IDs to launch the cluster in | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| eips | The elastic IP generated and attached to the instances of the cluster, if specified in 'elastic_ip_count' |
| id | The ID of the cluster |
| name | The name of the cluster |
| private\_ips | The private IPs of the instances of the cluster |
| security\_group\_id | The security group ID of the cluster |


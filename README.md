# Project to use for create an ECS Service on '[generic-spot-instance](https://github.com/mbasri/generic-spot-cluster)' infrastructure

[![LICENSE](https://img.shields.io/github/license/mbasri/terraform-aws-ecs-service)](https://github.com/mbasri/terraform-aws-ecs-service/blob/master/LICENSE)

A terraform module to create an Service on AWS ECS.

## How to create/destroy the infrastructure

### 1. Initialise you environmernt

```shell
aws configure
```

### 2. Create the infrastructure

```shell
terraform apply
```

### 3. Destroy the infrastructure

```shell
terraform destroy
```

## Dependencies of the infrastructure

* This project is based on the output of the [global infrastructure project](https://github.com/mbasri/aws-infrastructure) via the data block `terraform_remote_state`
* The project is built with the [v0.12.18](https://releases.hashicorp.com/terraform/) of Terraform

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image\_url | Docker repository URL | string | `empty` | yes |
| image\_tag | Version of the image to use | string | `latest` | no |
| container\_name | The name of the container to associate with the load balancer (as it appears in a container definition) | string | `empty` | yes |
| container\_port | The port on the container to associate with the load balancer | string | `80` | no |
| cpu | The number of cpu units used by the task | string | `256` | no |
| memory | The amount (in MiB) of memory used by the task | string | `512` | no |
| path\_pattern | Contains a single value item which is a list of path patterns to match against the request URL | string | `/` | no |
| health\_check\_path | The ping path that is the destination on the targets for health check | string | `/` | no |
| desired\_count | The number of instances of the task definition to place and keep running | string | `1` | no |
| ecs\_cluster\_name | Name of an ECS cluster | string | `/` | yes |
| alb\_name | Name of an ALB | string | `/` | yes |
| name | Default tags name to be applied on the infrastructure for the resources names | map | `...` | yes |
| tags | Default tags to be applied on the infrastructure | map | `...` | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_url | ALB FQDN name of the cluster |
| ecs_cluster_name | Cluster name |

## AWS architecture diagram

## Author

* [**Mohamed BASRI**](https://github.com/mbasri)

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details

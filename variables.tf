# Task
variable "image_url" {
  type        = string
  description = "Docker repository URL"
}

variable "image_tag" {
  type        = string
  description = "Version of the image to use"
  default     = "latest"
}

variable "container_name" {
  type        = string
  description = "The name of the container to associate with the load balancer (as it appears in a container definition)"
}

variable "container_port" {
  type        = string
  description = "(Required) The port on the container to associate with the load balancer"
  default     = "80"
}

variable "container_cpu" {
  type        = string
  description = "The number of cpu units used by the task"
  default     = "256"
}

variable "container_memory" {
  type        = string
  description = "The amount (in MiB) of memory used by the task"
  default     = "512"
}

variable "environment" {
  type        = list
  description = "List of variable to pass to the container"
  default     = []
}

variable "docker_labels" {
  type        = map
  description = "A key/value map of labels to add to the container"
  default     = {}
}

variable "port_mappings" {
  type        = list
  description = "The list of port mappings for the container"
  default     = []
}

variable "volumes_from" {
  type        = list
  description = "Data volumes to mount from another container"
  default     = []
}

variable "mount_points" {
  type        = list
  description = "The mount points for data volumes in your container"
  default     = []
}

# Target Group
variable "alb_name" {
  type        = string
  description = "Name of an ALB"
}

variable "path_pattern" {
  type        = string
  description = "Contains a single value item which is a list of path patterns to match against the request URL"
  default     = "/"
}

variable "health_check_path" {
  type        = string
  description = "The ping path that is the destination on the targets for health check"
  default     = "/"
}

# Service
variable "ecs_cluster_name" {
  type        = string
  description = "Name of an ECS cluster"
}

variable "desired_count" {
  type        = string
  description = "The number of instances of the task definition to place and keep running"
  default     = "2"
}

variable "min_capacity" {
  type        = string
  description = "The number min of instances of the task definition to place and keep running"
  default     = "2"
}

variable "max_capacity" {
  type        = string
  description = "The number max of instances of the task definition to place and keep running"
  default     = "4"
}

variable "tags" {
  type        = map
  description = "Default tags to be applied on 'app' application"
  default     = {
    "Technical:Terraform"      = "True"
  }
}

variable "name" {
  type        = map
  description = "Default tags name to be applied on the infrastructure for the resources names"
  default     = {}
}

locals {
  prefix_name = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"]])
  environment = jsonencode(
    concat(
      var.environment,
      [
        {
        "name" :"ENVIRONMENT",
        "value" : var.tags["Billing:Environment"]
        }
      ],
      [
        {
          "name": "APPLICATION",
          "value": var.tags["Billing:Application"]
        }
      ]
    )
  )

  docker_labels = jsonencode(
    merge(
      var.docker_labels,
      {
        "environment": var.tags["Billing:Environment"],
        "application": var.tags["Billing:Application"]
      }
    )
  )

  port_mappings = jsonencode(
    concat(
      var.port_mappings,
      [
        {
          containerPort = tonumber(var.container_port)
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
    )
  )

  volumes_from = concat(
    var.volumes_from,
    [
      {
        name      = "log"
        host_path = "/var/log/co"
      }
    ]
  )

  mount_points = jsonencode(
    concat(
      var.mount_points,
      [
        {
          sourceVolume  = "log"
          containerPath = "/var/log/toto"
        }
      ]
    )
  )
  
}

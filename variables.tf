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

variable "cpu" {
  type        = string
  description = "The number of cpu units used by the task"
  default     = "256"
}

variable "memory" {
  type        = string
  description = "The amount (in MiB) of memory used by the task"
  default     = "512"
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
  default     = "1"
}

/*
variable "container_definitions" {
  type        = string
  description = ""
}
*/

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
}

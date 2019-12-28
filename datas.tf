data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket = "tfstate.kibadex.net"
    key    = "infra/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name  = var.ecs_cluster_name
}

data "aws_lb" "main" {
  name = var.alb_name
}

data "aws_lb_listener" "main_80" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "template_file" "main" {
  template = file("${path.module}/files/task-definition.json.tpl")

  vars = {
    awslogs_region   = data.terraform_remote_state.main.outputs.region
    awslogs_group    = "/aws/ecs/${var.ecs_cluster_name}"
    
    image_url        = "${var.image_url}:${var.image_tag}"
    container_name   = var.container_name
    container_port   = var.container_port
    container_cpu    = var.container_cpu
    container_memory = var.container_memory
    docker_labels    = local.docker_labels
    environment      = local.environment
    port_mappings    = local.port_mappings
    mount_points     = local.mount_points
  }
}

data "template_file" "as_ecs" {
  template = file("${path.module}/files/iam/as-ecs-policy.json.tpl")
}

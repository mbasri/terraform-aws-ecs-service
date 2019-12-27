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
  template = file("${path.module}/files/task-definition.json")

  vars = {
    image_url       = "${var.image_url}:${var.image_tag}"
    container_name  = var.container_name
    container_port  = var.container_port
    cpu_instance    = var.cpu
    memory_instance = var.memory
  }
}

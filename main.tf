

resource "aws_ecs_task_definition" "main" {
  family                   = join("-", [local.prefix_name, "pri", "tsk"])
  container_definitions    = data.template_file.main.rendered
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  //task_role_arn            = data.aws_iam_role.ecr_role.name
  //execution_role_arn       = data.aws_iam_role.ecr_role.name

  dynamic "volume" {
    for_each  = local.volumes_from
    content {
      name      = volume.value["name"]
      host_path = volume.value["host_path"]
    }
  }

  tags    = merge(var.tags, map("Name", join("-", [local.prefix_name, "pri", "tsk"])))
}

resource "aws_ecs_service" "main" {
  name                = var.container_name
  cluster             = data.aws_ecs_cluster.main.arn
  task_definition     = aws_ecs_task_definition.main.arn
  desired_count       = var.desired_count
  scheduling_strategy = "REPLICA"
  launch_type         = "EC2"

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
      ignore_changes = [desired_count]
    }
  //tags    = merge(var.tags, map("Name", join("-", [local.prefix_name, "pri", "svc"])))
}

resource "aws_appautoscaling_target" "main" {
  min_capacity       = 2
  max_capacity       = 4
  resource_id        = "service/${var.ecs_cluster_name}/${var.container_name}"
  #role_arn           = aws_iam_role.as_ecs.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "scale-cpu-policy"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 180

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "scale-memory-policy"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 180

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

resource "aws_alb_target_group" "main" {
  name                  = join("-", [local.prefix_name, "pri", "tgr"])
  port                  = "80"
  protocol              = "HTTP"
  vpc_id                = data.terraform_remote_state.main.outputs.vpc_id
  deregistration_delay  = "60"
  
  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    interval            = "30"
    timeout             = "10"
    matcher             = "200"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
  }

  tags  = merge(
      var.tags,
      map("Name", join("-", [local.prefix_name, "pri", "tsk"]))
    )
}

resource "aws_lb_listener_rule" "main" {
  listener_arn          = data.aws_lb_listener.main_80.arn

  action {
    type                = "forward"
    target_group_arn    = aws_alb_target_group.main.arn
  }

  condition {
    field               = "path-pattern"
    values              = [var.path_pattern]
  }
}

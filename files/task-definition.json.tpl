[
  {
    "name": "${container_name}",
    "image": "${image_url}",
    "cpu": ${container_cpu},
    "memory": ${container_memory},
    "environment": ${environment},
    "dockerLabels": ${docker_labels},
    "portMappings": ${port_mappings},
    "mountPoints": ${mount_points},
    "essential": true,
    "logConfiguration": {  
      "logDriver": "awslogs",
      "options":  {
          "awslogs-region": "${awslogs_region}",
          "awslogs-group": "${awslogs_group}",
          "awslogs-stream-prefix": "/"
      }
    }
  }
]
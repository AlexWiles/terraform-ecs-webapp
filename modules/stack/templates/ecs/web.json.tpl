[
  {
    "command": ${command},
    "name": "${name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "environment": [
      { "name": "RAILS_ENV", "value": "${rails_env}" },
      { "name": "RAILS_SERVE_STATIC_FILES", "value": "1" },
      { "name": "NODE_ENV", "value": "${node_env}" },
      { "name": "AWS_REGION", "value": "${aws_region}" },
      { "name": "POSTGRES_URL", "value": "postgres://${postgres_host}" },
      { "name": "FILE_UPLOAD_BUCKET", "value": "${file_upload_bucket}" },
      { "name": "REDIS_URL", "value": "${redis_url}" },
      { "name": "RAILS_MASTER_KEY", "value": "${rails_env_key}" },
      { "name": "CLOUDFRONT_ENDPOINT", "value": "${cloudfront_endpoint}" }
    ]
  }
]

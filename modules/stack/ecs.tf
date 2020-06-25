# https://www.terraform.io/docs/providers/aws/r/ecs_service.html

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}_cluster"
}

data "template_file" "web" {
  template = file("${path.module}/templates/ecs/web.json.tpl")

  vars = {
    name           = "${var.environment}_web"
    command        = jsonencode(["./bin/rails", "s", "-b", "0.0.0.0"])
    app_image      = "${aws_ecr_repository.app_image_repository.repository_url}:${var.app_git_hash}"
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    log_group      = aws_cloudwatch_log_group.app_log_group.name

    # environment variables
    rails_env            = var.environment
    node_env             = var.environment
    postgres_host        = aws_db_instance.app_db.address
    aws_region           = var.aws_region
    file_upload_bucket   = local.bucket_names.uploads
    redis_url            = local.redis_url
    rails_env_key        = var.rails_env_key
    cloudfront_endpoint  = aws_cloudfront_distribution.rails_assets.domain_name
  }
}


resource "aws_ecs_task_definition" "web" {
  family                   = "web"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.web.rendered
}

resource "aws_ecs_service" "main" {
  name            = "${var.environment}_web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.public.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "${var.environment}_web"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}


data "template_file" "sidekiq" {
  template = file("${path.module}/templates/ecs/web.json.tpl")

  vars = {
    name           = "${var.environment}_sidekiq"
    command        = jsonencode(["./bin/bundle", "exec", "sidekiq"])
    app_image      = "${aws_ecr_repository.app_image_repository.repository_url}:${var.app_git_hash}"
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    log_group      = aws_cloudwatch_log_group.app_log_group.name

    health_check_grace_period_seconds = 60

    # environment variables
    rails_env            = var.environment
    node_env             = var.environment
    postgres_host        = aws_db_instance.app_db.address
    aws_region           = var.aws_region
    file_upload_bucket   = local.bucket_names.uploads
    redis_url            = local.redis_url
    rails_env_key        = var.rails_env_key
    cloudfront_endpoint  = aws_cloudfront_distribution.rails_assets.domain_name
  }
}

resource "aws_ecs_task_definition" "sidekiq" {
  family                   = "sidekiq"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.sidekiq.rendered
}

resource "aws_ecs_service" "sidekiq" {
  name            = "${var.environment}_sidekiq"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.sidekiq.arn
  desired_count   = var.sidekiq_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.public.*.id
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

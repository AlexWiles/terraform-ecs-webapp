resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "${var.environment}/ecs/app"
  retention_in_days = 5

  tags = {
    Name = "${var.environment}-app-log-group"
    Environment =  var.environment
  }
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "${var.environment}-app-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}


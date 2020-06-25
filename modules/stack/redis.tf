resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name        = "${var.environment}-elasticache-subnet-group"
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "mf-${var.environment}-redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  security_group_ids = [aws_security_group.redis_instance.id]
  subnet_group_name   = aws_elasticache_subnet_group.elasticache_subnet_group.id
}

locals {
  redis_url = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:6379/0"
}

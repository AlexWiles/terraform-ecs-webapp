locals {
  bucket_names = {
    uploads = "mf-${var.environment}-file-uploads"
    secrets = "mf-${var.environment}-secrets"
  }
}
resource "aws_s3_bucket" "uploads" {
  bucket = local.bucket_names.uploads
  acl    = "private"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    max_age_seconds = 3000
    allowed_headers = ["*"]
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["PUT", "POST"]
    max_age_seconds = 3000
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "secrets" {
  bucket = local.bucket_names.secrets
  acl    = "private"
}

data "template_file" "secrets" {
  template = file("${path.module}/templates/secrets.tpl")

  vars = {
    rails_env          = var.environment
    rails_env_key      = var.rails_env_key
    node_env           = var.environment
    postgres_host      = aws_db_instance.app_db.address
    ecr_repo           = aws_ecr_repository.app_image_repository.repository_url
    alb_endpoint       = aws_alb.main.dns_name
    aws_region         = var.aws_region
    file_upload_bucket = local.bucket_names.uploads
    redis_url          = local.redis_url
    cloudfront_endpoint = aws_cloudfront_distribution.rails_assets.domain_name


  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.secrets.id
  key = "web_env"
  content = data.template_file.secrets.rendered
}

data "template_file" "migrate" {
  template = file("${path.module}/templates/migrate.tpl")

  vars = {
    ecr_repo    = aws_ecr_repository.app_image_repository.repository_url
    aws_region  = var.aws_region
    bucket_name = local.bucket_names.secrets
  }
}

resource "aws_s3_bucket_object" "migrate" {
  bucket = aws_s3_bucket.secrets.id
  key = "migrate"
  content = data.template_file.migrate.rendered
}

data "template_file" "push-image" {
  template = file("${path.module}/templates/push-image.tpl")

  vars = {
    ecr_repo    = aws_ecr_repository.app_image_repository.repository_url
    aws_region  = var.aws_region
  }
}

resource "aws_s3_bucket_object" "push-image" {
  bucket = aws_s3_bucket.secrets.id
  key = "push-image"
  content = data.template_file.push-image.rendered
}

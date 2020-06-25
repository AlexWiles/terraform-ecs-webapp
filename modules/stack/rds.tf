resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment}_rds_subnet_group"
  description = "Our main group of subnets for RDS"
  subnet_ids  = aws_subnet.public.*.id
}

resource "aws_db_instance" "app_db" {
  engine               = "postgres"
  engine_version       = "11.5"
  name                 = "${var.environment}_app"
  allocated_storage    = var.app_postgres_storage
  instance_class       = var.app_postgres_instance_type
  username             = var.app_postgres_user
  password             = var.app_postgres_password

  skip_final_snapshot      = false
  backup_retention_period  = 5

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.app_db.id]
}

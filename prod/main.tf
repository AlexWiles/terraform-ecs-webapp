module "prod_stack" {
  source = "../modules/stack"

  app_name =
  domain_name =
  aws_region =
  environment = "production"
  app_count = 1
  sidekiq_count = 1

  app_git_hash =

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  fargate_cpu = 256
  fargate_memory = 512

  app_postgres_instance_type = "db.t3.small"
  app_postgres_storage = 100
  app_postgres_user =
  app_postgres_password =


  rails_env_key        =

  public_key_for_ec2 =

  misc_instance_ami = "ami-0db2f1da78295bc11"
  misc_instance_type = "t3.small"
}

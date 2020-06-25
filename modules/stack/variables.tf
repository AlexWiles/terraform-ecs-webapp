# variables.tf

variable "app_name" {
  description = "App Name"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = 2
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "sidekiq_count" {
  description = "Number of sidekiq containers"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
}

variable "public_key_for_ec2" {
  description = "Public key for ec2 misc instance"
}

variable "domain_name" {
  description = "The primary domain name"
}

variable "misc_instance_ami" {
  description = "The ami ID for the misc instance"
  default = "ami-*"
}

variable "rails_env_key" {
  description = "credentials key"
}

variable "app_postgres_instance_type" {
  description = "app db instance type"
}

variable "app_postgres_storage" {
  description = "app db storage"
}

variable "app_postgres_user" {
  description = "app postgres user"
}

variable "app_postgres_password" {
  description = "app postgres password"
}

variable "misc_instance_type" {
  description = "instance class"
}

variable "app_git_hash" {
  description = "git hash of the image that ecs should deploy"
}

# Terraform ECS web app deployment for Rails
This is a fully working Terraform setup to run a Rails application on AWS ECS

With some small tweaks this can run most any dockerized standard web app.

# Uses the following AWS technologies

### ECR


Docker images are stored in an ECR repository.

### ECS Fargate
The application runs on ECS Fargate.

### RDS
The database is a Postgres RDS instance.

### Redis
A Redis instance is accessible from the applications running on Fargate.

### EC2
A ec2 instance is spun up for SSH access to the subnet.

### ALB
An ALB routes traffic to the fargat containers

### Cloudfront
A cloudfront CDN is spun up.

### S3
There is a file upload bucket that sits behind the Cloudfront CDN.
An environment file is created from the terraform environment and uploaded to a private bucket.

### IAM
The services are locked down with IAM.

### Networking and security
The app sits in a subnet and uses security groups to restrict traffic flow.

### Cloudwatch logs
Logs from fargate are sent to cloudwatch.

### Route 53
Route 53 is used for DNS.

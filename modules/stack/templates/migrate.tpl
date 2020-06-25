#!/bin/bash
sudo $(aws ecr get-login --no-include-email --region ${aws_region})
sudo docker pull ${ecr_repo}:latest
aws s3 cp s3://${bucket_name}/web_env .
sudo docker run --env-file web_env -it ${ecr_repo}:latest ./bin/rails db:migrate
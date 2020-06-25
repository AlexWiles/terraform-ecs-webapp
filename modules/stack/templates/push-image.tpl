#!/bin/bash
docker-compose build web
TAG=$(git rev-parse --short HEAD)
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repo}
docker tag uncomma_web:latest ${ecr_repo}:$TAG
docker push ${ecr_repo}:$TAG
#!/bin/bash

# Container name
container_name="vaccination-appointment"

AWS_DEFAULT_REGION=$(aws ssm get-parameter --name default-region-aws --query "Parameter.Value" --output text)
AWS_ACCOUNT_ID=$(aws ssm get-parameter --name account-id --query "Parameter.Value" --output text)

echo Logging in to Amazon ECR...
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

IMAGE_TAG=appointment-latest
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/vaccination-system-images:$IMAGE_TAG
docker tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/vaccination-system-images:$IMAGE_TAG $container_name:latest

docker stop $container_name
docker rm $container_name

docker run -d -it -p 8001:19090 --env-file ../.env --name $container_name $container_name:latest

# docker compose -f ../docker-compose.prod.yaml down -v
# docker image prune -f
# docker buildx prune -f
# docker compose -f ../docker-compose.prod.yaml up -d

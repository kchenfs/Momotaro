#!/bin/bash

container_name=lambda_layer_docker
docker_image=kencfs/generate_layer:latest

# Build the Docker image from a Dockerfile
docker pull $docker_image

# Run a detached Docker container
docker run -td --name $container_name $docker_image

# Copy requirements.txt and docker_install.sh into the container
docker cp requirements.txt "$container_name":/
docker cp docker_install.sh "$container_name":/

# Execute the docker_install.sh script directly inside the container
docker exec -i "$container_name" /bin/bash /docker_install.sh

# Copy files from the container to the host
docker cp $container_name:/python.zip python.zip

# Stop and remove the container
docker stop "$container_name"
docker rm "$container_name"

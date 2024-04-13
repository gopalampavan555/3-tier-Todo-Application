#!/bin/bash
set -e

docker stop uiapp
docker rm uiapp
docker rmi kalyan555/ui
# Pull the Docker image from Docker Hub
docker pull kalyan555/ui

# Run the Docker image as a container
docker run -d --name uiapp -p 3000:3000 kalyan555/ui

#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull kalyan555/ui

# Run the Docker image as a container
docker run -d -p 3000:3000 kalyan555/ui
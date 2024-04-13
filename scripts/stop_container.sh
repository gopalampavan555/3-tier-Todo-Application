#!/bin/bash
set -e
docker stop uiapp
docker rm uiapp
docker rmi kalyan555/ui

#!/bin/bash
# Builds and runs the docker deploy step, which in turn builds our app in Rocky8.
# The compressed release is then copied out from the container.

sudo docker build -f deploy.Dockerfile --no-cache --output release .
sudo chown niko release


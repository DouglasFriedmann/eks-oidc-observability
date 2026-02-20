#!/usr/bin/env bash
set -e

IMAGE_NAME=eks_observability_local

docker build -t $IMAGE_NAME ./app
echo "Built $IMAGE_NAME"

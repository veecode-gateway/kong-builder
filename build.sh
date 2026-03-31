#!/bin/bash
set -euo pipefail

IMAGE="veecode/kong-builder:latest"

docker build -t "$IMAGE" .
docker push "$IMAGE"

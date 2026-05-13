#!/bin/bash
set -euo pipefail

IMAGE="veecode/kong-builder:local"

docker build -t "$IMAGE" .
docker push "$IMAGE"

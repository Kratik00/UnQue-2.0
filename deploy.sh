#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="unque-backend"
IMAGE_NAME="${IMAGE_NAME:-unque-backend:1.0}"
CONTAINER_PORT="${PORT:-3000}"
HOST_PORT="${HOST_PORT:-3000}"
CERT_DIR="${CERT_DIR:-./certs}"
CA_FILE="$CERT_DIR/global-bundle.pem"

# Validate configuration
: "${MONGO_URL:?MONGO_URL is required}"
: "${JWT_SECRET:?JWT_SECRET is required}"

if [[ "${DB_TYPE:-}" != "documentdb" ]]; then
  exit 1
fi

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed."
  exit 1
fi

docker info >/dev/null

mkdir -p "$CERT_DIR"

if [[ ! -s "$CA_FILE" ]]; then
  curl --fail --silent --show-error \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    -o "$CA_FILE"
fi

# Build image if unavailable
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  if [[ -f "./unque-backend.tar" ]]; then
    echo "Loading Docker image..."
    docker load -i ./unque-backend.tar
  elif [[ -f "./Dockerfile" ]]; then
    echo "Building Docker image..."
    docker build -t "$IMAGE_NAME" .
  else
    echo "ERROR: Docker image and Dockerfile not found."
    exit 1
  fi
fi

# Replace previous container
docker rm -f "$APP_NAME" >/dev/null 2>&1 || true

# Start application
docker run -d \
  --name "$APP_NAME" \
  --restart unless-stopped \
  -p "$HOST_PORT:$CONTAINER_PORT" \
  -e PORT="$CONTAINER_PORT" \
  -e DB_TYPE=documentdb \
  -e MONGO_URL="$MONGO_URL" \
  -e JWT_SECRET="$JWT_SECRET" \
  -e DOCDB_CA_FILE="/app/certs/global-bundle.pem" \
  -v "$(pwd)/$CA_FILE:/app/certs/global-bundle.pem:ro" \
  "$IMAGE_NAME"

sleep 5

if [[ "$(docker inspect -f '{{.State.Running}}' "$APP_NAME")" == "true" ]]; then
  echo "UnQue container is running."
  docker logs --tail 30 "$APP_NAME"
else
  echo "ERROR: Application failed to start."
  docker logs "$APP_NAME"
  exit 1
fi
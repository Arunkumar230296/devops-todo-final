#!/usr/bin/env bash

set -euo pipefail

APP_NAME="devops-todo-final"
IMAGE_NAME="${IMAGE_NAME:-ghcr.io/arunkumar230296/devops-todo-final:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-devops-todo-final}"
APP_PORT="${APP_PORT:-8080}"
DATABASE_URL="${DATABASE_URL:-postgresql://todo_user:todo_password@localhost:5432/todo_db}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

install_docker_if_missing() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker already installed"
    return
  fi

  log "Docker not found. Installing Docker on Ubuntu..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
}

run_container() {
  log "Pulling latest image: $IMAGE_NAME"
  sudo docker pull "$IMAGE_NAME"

  if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "Removing existing container"
    sudo docker stop "$CONTAINER_NAME" || true
    sudo docker rm "$CONTAINER_NAME" || true
  fi

  log "Starting new container"
  sudo docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "${APP_PORT}:8080" \
    -e DATABASE_URL="$DATABASE_URL" \
    "$IMAGE_NAME"
}

health_check() {
  log "Checking app health"

  for i in {1..10}; do
    if curl -fsS "http://localhost:${APP_PORT}/health"; then
      log "Application is healthy"
      return
    fi
    log "Retrying health check $i/10"
    sleep 3
  done

  log "Application failed health check"
  exit 1
}

main() {
  log "Starting deployment for $APP_NAME"
  install_docker_if_missing
  run_container
  health_check
  log "Deployment completed"
}

main "$@"
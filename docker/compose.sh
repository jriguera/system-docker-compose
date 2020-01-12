#!/bin/bash
set -eo pipefail

COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml}
COMPOSE_PROJECT_DIRECTORY=${COMPOSE_PROJECT_DIRECTORY:-$(dirname $COMPOSE_FILE)}
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-system}

case "${1}" in
    start)
        docker-compose rm -v --force
        docker-compose pull --quiet
        docker-compose up -d --no-color --remove-orphans
        ;;
    reload)
        docker-compose pull --quiet
        docker-compose build --pull
        docker-compose up -d --no-color --remove-orphans
        ;;
    stop)
        docker-compose down
        ;;
    status)
        docker-compose ps
        ;;
    top)
        docker-compose top
        ;;
    run)
        shift
        docker-compose "$@"
        ;;
    help|*)
        echo "Usage: [ start | reload | stop | status | run <list-docker-compose-options> ]"
        echo "  docker-compose wrapper to manage 'system' stack in <stackdir> folder"
        echo "  Default <stackdir> folder: ${COMPOSE_PROJECT_DIRECTORY}"
        echo "  Settings in <stackdir> (${COMPOSE_PROJECT_DIRECTORY}): ${COMPOSE_FILE}"
        echo
        ;;
esac


#!/bin/bash
set -eo pipefail

# if command starts with an option, prepend docker-compose
if [[ "${1}" != 'docker-compose' ]]
then
	set -- docker-compose "$@"
fi

exec "$@"

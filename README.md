# system-docker-compose

Docker image to run docker-Compose in a Linux and/or Raspberry Pi. The idea is
define a system docker-compose service which spins up docker stacks when the
system boots. The service is managed with systemd and a wrapper script 
`system-docker-compose` and it automatically define systemd timers (cron) to
keep the Docker containers updated.


### Develop and test builds

Use the script:

```
docker-build.sh
```

or in `docker` folder, type:

```
docker build . -t dockercompose
```

### Create final release and publish to Docker Hub

This repository uses GitHub Actions to build the docker image and debian package.
To release a new version and push the image to DockerHub, please use an annotated tag: `git tag -a v3.13 -m "new release"`
and push with `git push --tags`, the github actions will do the rest:
create a debian package, push the docker image to DockerHub and create a release.

```
# Old script
create-release.sh
```

### Run

Just use the wrapper script `system-docker-compose`. The script uses the same arguments
as docker-compose original program plus a first argument which is the configuration
folder (i.e. where the `docker-compose.yml` is):

```
system-docker-compose start
```

Example files in `/etc/docker-compose`:

`docker-compose.yml`
```
version: '3'

# Variables defined in .env file

services:

  portainer:
    container_name: portainer
    image: portainer/portainer
    labels:
      description: "Portainer: Web interface to manage docker containers"
      system: true
    volumes:
    - /data/docker/portainer:/data
    - /var/run/docker.sock:/var/run/docker.sock
    ports:
    - "9000:9000"
    networks:
    - frontend
    restart: always
    deploy:
      replicas: 1
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s

networks:
  backend:
  frontend:
    driver: bridge

```

`config.env`
```
# Name of the docker-compose project (by default is the name of the folder)
NAME=system
# Disable the service with 0
ENABLED=1
# Docker image (:version) with docker-compose (default)
IMAGE="jriguera/dockercompose"
```

`.env`
```
# secrets
PASSWORD=hola
```

## Enable systemd

Install the units, be aware those units need a `/data` mountpoint!

```
# docker-compose services
install -m 644 -g root -o root systemd/docker-compose.target /lib/systemd/system
install -m 644 -g root -o root systemd/docker-compose@.service /lib/systemd/system
install -m 644 -g root -o root systemd/docker-compose-refresh@.service /lib/systemd/system
install -m 644 -g root -o root systemd/docker-compose-refresh.service /lib/systemd/system
install -m 644 -g root -o root systemd/docker-compose-refresh.timer /lib/systemd/system
# binary wrapper
install -m 755 -g root -o root bin/system-docker-compose /usr/bin/system-docker-compose
```

Configure the service and enable the units:
```
COMPOSE_CONFIG_FOLDER="/etc/docker-compose"
# Install docker dompose services
mkdir -p $COMPOSE_CONFIG_FOLDER
# Create the configuration files: docker-compose.yml and config.env (see example)

systemctl enable docker-compose.target
# Enable docker-compose boot service
systemctl enable "docker-compose@`systemd-escape --path ${COMPOSE_CONFIG_FOLDER}`.service"
systemctl enable "docker-compose-refresh@`systemd-escape --path ${COMPOSE_CONFIG_FOLDER}`.service"
```

# Author

Jose Riguera <jriguera@gmail.com>

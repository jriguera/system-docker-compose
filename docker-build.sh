#!/usr/bin/env bash

DOCKER=docker
NAME="dockercompose"

pushd docker
    $DOCKER build \
      --build-arg TZ=$(timedatectl  | awk '/Time zone:/{ print $3 }') \
      .  -t $NAME
popd


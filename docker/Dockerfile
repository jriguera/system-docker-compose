# docker-compose Docker

# docker build . -t dockercompose
# docker run --name compose -v /var/run/docker.sock:/var/run/docker.sock -v /root:/root -v $(pwd):$(pwd) -w $(pwd) -d dockercompose up -d

FROM "python:3.8-alpine3.12"

ARG VERSION=1.27.4
ARG DOCKER_BASE_URL="https://download.docker.com/linux/static/stable/"
ARG DOCKER_BIN_TGZ="docker-19.03.9.tgz"
ARG MYVERSION=jose0
ARG UID=1000
ARG GUID=1000
ARG TZ=Europe/Amsterdam

LABEL org.opencontainers.image.vendor="Jose Riguera"
LABEL org.opencontainers.image.description="Docker image to run docker-compose as a systemd service"
LABEL org.opencontainers.image.title="dockercompose"
LABEL org.opencontainers.image.version="${VERSION}-${MYVERSION}"
LABEL maintainer="Jose Riguera <jriguera@gmail.com>"

ENV LANG=en_US.utf8
ENV LC_ALL=C.UTF-8
ENV ENTRYPOINT="/docker-entrypoint-initdb.d"

RUN set -xe                                                                 && \
    apk -U upgrade                                                          && \
    # Installing Alpine packages
    apk add --no-cache \
        tzdata \
        bash \
        openssl \
        libffi \
        ca-certificates \
        curl \
        yaml \
        glib \
        jq \
                                                                            && \
    # Timezone
    cp "/usr/share/zoneinfo/${TZ}" /etc/localtime                           && \
    echo "${TZ}" > /etc/timezone                                            && \
    # clean up
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* ~/.cache

SHELL ["/bin/bash", "-c"]
COPY requirements.txt requirements.txt
RUN set -xe                                                                 && \
    addgroup -g "${GUID}" compose                                           && \
    adduser -h / -D -G compose -s /bin/bash -u "${UID}" compose             && \
    # Install build dependencies
    apk add --no-cache -t .build  gcc make libc-dev libffi-dev openssl-dev  && \
    # Install docker bin
    [[ $(arch) == arm* ]] && DA="armhf" || DA=$(arch)                       && \
    curl -fsSL -o /tmp/bin.tgz "${DOCKER_BASE_URL}${DA}/${DOCKER_BIN_TGZ}"  && \
    tar xvf /tmp/bin.tgz docker/docker -C /tmp --strip-components 1         && \
    mv /tmp/docker /usr/bin/docker                                          && \
    chmod +x /usr/bin/docker                                                && \
    # Install Python Docker Compose
    pip3 install --no-cache-dir docker-compose=="${VERSION}"                && \
    pip3 install --no-cache-dir -r requirements.txt                         && \
    # clean up
    apk del .build                                                          && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* ~/.cache

COPY *.sh /usr/local/bin/
RUN set -xe                                                                 && \
    chmod a+x /usr/local/bin/*                                              && \
    ln -s /usr/local/bin/compose.sh /usr/local/bin/docker-entrypoint.sh     && \
    ln -s /usr/local/bin/compose.sh /docker-entrypoint.sh                   && \
    ln -s /usr/local/bin/compose.sh /run.sh                                 && \
    mkdir -p $ENTRYPOINT

ENTRYPOINT ["/run.sh"]


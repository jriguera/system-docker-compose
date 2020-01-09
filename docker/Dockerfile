# docker-compose Docker

# docker build . -t dockercompose
# docker run --name compose -v /var/run/docker.sock:/var/run/docker.sock -v /root:/root -v $(pwd):$(pwd) -w $(pwd) -d dockercompose up -d

ARG ARCH=arm32v6
FROM "${ARCH}/python:3.8-alpine3.11"

ARG VERSION=1.25.1
ARG DOCKER_BASE_URL="https://download.docker.com/linux/static/stable/"
ARG DOCKER_BIN_TGZ="docker-19.03.5.tgz"
ARG MYVERSION=jose1
ARG UID=1000
ARG GUID=1000
ARG TZ=Europe/Amsterdam
ARG ARCH

LABEL org.label-schema.docker.schema-version="1.0"
LABEL org.label-schema.vendor="Jose Riguera"
LABEL org.label-schema.description="Docker compose image based on alpine for the Raspberry Pi."
LABEL org.label-schema.name="rpi-dockercompose"
LABEL org.label-schema.version="${VERSION}-${MYVERSION}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.url="https://hub.docker.com/r/jriguera/rpi-dockercompose"
LABEL org.label-schema.vcs-url="https://github.com/jriguera/docker-rpi-dockercompose"
LABEL maintainer="Jose Riguera <jriguera@gmail.com>"
LABEL architecture="${ARCH}"

ENV LANG=en_US.utf8
ENV LC_ALL=C.UTF-8
ENV ARCH="${ARCH}"
ENV CROSS_COMPILE=/usr/bin/

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

COPY requirements.txt requirements.txt
RUN set -xe                                                                 && \
    addgroup -g "${GUID}" compose                                           && \
    adduser -h / -D -G compose -s /bin/bash -u "${UID}" compose             && \
    # Install build dependencies
    apk add --no-cache -t .build  gcc make libc-dev libffi-dev openssl-dev  && \
    # Install docker bin
    test "$ARCH" == "arm32v6" && DA="armhf" || DA="x86_64"                  && \
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
    mkdir -p /docker-entrypoint-initdb.d

ENTRYPOINT ["/run.sh"]


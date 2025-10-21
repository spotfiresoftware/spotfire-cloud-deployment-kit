#
# spotfire-base container for latest released stable Debian
#
ARG DEBIAN_IMAGE_TAG=13-slim

#
# common java-base
#
FROM debian:${DEBIAN_IMAGE_TAG} AS spotfire-base

LABEL org.opencontainers.image.title="spotfire/spotfire-base" \
    org.opencontainers.image.description="Base image for Spotfire® container images" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.'


RUN apt-get update \
  && apt-get upgrade -y \
  && mkdir -p /usr/share/man/man1 \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     ca-certificates-java \
     unzip \
     cabextract \
     brotli \
     libjemalloc2 \
     libmimalloc3 \
     curl \
  && apt-get clean all

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget apt-transport-https gpg \
  && wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
  && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y temurin-21-jdk --no-install-recommends \
  && apt-get clean all

RUN groupadd -g 1000 spotfire \
  && useradd --uid 1000 --gid 1000 --home /opt/spotfire/ --shell=/bin/bash spotfire \
  && mkdir -p /opt/spotfire/ \
  && chown -R spotfire:spotfire /opt/spotfire/

#
# spotfire-base container for latest released stable Debian
#
ARG DEBIAN_IMAGE_TAG=12-slim

#
# common java-base
#
FROM debian:$DEBIAN_IMAGE_TAG as spotfire-base

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
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     openjdk-17-jre-headless \
     unzip \
     cabextract \
  && apt-get clean all

RUN groupadd -g 1000 spotfire \
  && useradd --uid 1000 --gid 1000 --home /opt/spotfire/ --shell=/bin/bash spotfire \
  && mkdir -p /opt/spotfire/ \
  && chown -R spotfire:spotfire /opt/spotfire/

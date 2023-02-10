#
# spotfire-base container for latest released stable Debian
#
ARG DEBIAN_TAG=stable-slim

#
# common java-base
#
FROM debian:$DEBIAN_TAG as spotfire-base

ARG DEBIAN_TAG
LABEL org.opencontainers.image.title="tibco/spotfire-base" \
    org.opencontainers.image.description="Base image for TIBCO Spotfire® container images" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.'

RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     openjdk-17-jre-headless \
     unzip \
     cabextract \
  && apt-get clean all

RUN groupadd -g 1000 spotfire \
  && useradd --uid 1000 --gid 1000 --home /opt/tibco/ --shell=/bin/bash spotfire \
  && mkdir -p /opt/tibco/ \
  && chown -R spotfire:spotfire /opt/tibco/

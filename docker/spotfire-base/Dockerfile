#
# spotfire-server container for Debian 11
#
ARG DEBIAN_TAG=bullseye-20220328-slim

#
# common java-base
#
FROM debian:$DEBIAN_TAG as spotfire-base

# TODO: remove iputils & curl
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     openjdk-11-jre-headless \
     iputils-ping \
     curl \
     unzip \
     cabextract \
  && apt-get clean all

RUN groupadd --system spotfire \
  && useradd --system --gid spotfire --home-dir=/opt/tibco/ --shell=/bin/bash spotfire \
  && mkdir -p /opt/tibco/ \
  && chown -R spotfire:spotfire /opt/tibco/

ARG IMAGE_BUILD_ID=latest

#
# extract Spotfire node manager from tsnm package
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as extract

ARG SPOTFIRE_NODEMANAGER_VERSION
ADD build/tsnm-${SPOTFIRE_NODEMANAGER_VERSION}.x86_64.tar.gz /tmp
RUN rm -rf /tmp/tsnm-*/jdk/

#
# spotfire-node-manager specific
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as spotfire-node-manager

ENV SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

# 
# TODO: remove iputils & curl. Note: unzip is needed by specialized containers for installing services at build time.
# 
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends iproute2 iputils-ping curl zip unzip jq \
  && apt-get clean all

# Default values for configuring node manager
ENV NODEMANAGER_HOST_NAMES="" \
    NODEMANAGER_REGISTRATION_PORT=9080 \
    NODEMANAGER_COMMUNICATION_PORT=9443 \
    SERVER_BACKEND_REGISTRATION_PORT=9080 \
    SERVER_BACKEND_COMMUNICATION_PORT=9443

EXPOSE 9080 9443 9501

RUN mkdir -p /opt/tibco/tsnm && chown -R spotfire:spotfire /opt/tibco/tsnm
WORKDIR /opt/tibco/tsnm

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-*.x86_64 ./
COPY --chown=spotfire:spotfire entrypoint.sh ./
COPY --chown=spotfire:spotfire scripts/ ./scripts/

USER spotfire
ENTRYPOINT ["./entrypoint.sh"]

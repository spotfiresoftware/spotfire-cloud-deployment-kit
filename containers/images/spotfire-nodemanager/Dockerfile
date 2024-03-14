ARG SPOTFIRE_BASE_IMAGE_TAG
ARG SPOTFIRE_NODEMANAGER_VERSION

#
# extract Spotfire node manager from nodemanager package
#
FROM spotfire/spotfire-base:${SPOTFIRE_BASE_IMAGE_TAG} as extract

ARG SPOTFIRE_NODEMANAGER_VERSION
ADD build/spotfirenodemanager-${SPOTFIRE_NODEMANAGER_VERSION}.x86_64.tar.gz /tmp
RUN rm -rf /tmp/nodemanager-*/jdk/ /tmp/nodemanager-*/nm/upgrade/

#
# spotfire-nodemanager specific
#
FROM spotfire/spotfire-base:${SPOTFIRE_BASE_IMAGE_TAG} as spotfire-nodemanager

ARG SPOTFIRE_NODEMANAGER_VERSION
LABEL org.opencontainers.image.title="spotfire/nodemanager" \
    org.opencontainers.image.description="Spotfire® node manager is the service used for controlling the Spotfire services." \
    org.opencontainers.image.version="${SPOTFIRE_NODEMANAGER_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® node manager" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

ENV SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends iproute2 zip unzip jq \
  && apt-get clean all

# Default values for configuring node manager
ENV NODEMANAGER_REDIRECT_STDOUTERR="N" \
    NODEMANAGER_LOG_APPENDER="Console" \
    NODEMANAGER_HOST_NAMES="" \
    NODEMANAGER_REGISTRATION_PORT=9080 \
    NODEMANAGER_COMMUNICATION_PORT=9443 \
    SERVER_BACKEND_REGISTRATION_PORT=9080 \
    SERVER_BACKEND_COMMUNICATION_PORT=9443


# Set up default values for node manager logging
ENV LOGGING_NMLOG_SIZE=10MB \
    LOGGING_NMLOG_MAX=2 \
    LOGGING_NMPERFORMANCELOG_SIZE=10MB \
    LOGGING_NMPERFORMANCELOG_MAX=2


EXPOSE 9080 9443 9501

RUN mkdir -p /opt/spotfire/nodemanager && chown -R spotfire:spotfire /opt/spotfire/nodemanager
WORKDIR /opt/spotfire/nodemanager

COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-*.x86_64 ./
COPY --chown=spotfire:spotfire entrypoint.sh ./
COPY --chown=spotfire:spotfire scripts/ ./scripts/

USER spotfire
CMD ["./entrypoint.sh"]

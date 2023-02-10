ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION

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

ARG SPOTFIRE_NODEMANAGER_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-node-manager" \
    org.opencontainers.image.description="TIBCO Spotfire® node manager is the service used for controlling the Spotfire services." \
    org.opencontainers.image.version="${SPOTFIRE_NODEMANAGER_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® node manager" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

ENV SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends iproute2 zip unzip jq \
  && apt-get clean all

# Default values for configuring node manager
ENV NODEMANAGER_REDIRECT_STDOUTERR="N" \
    NODEMANAGER_HOST_NAMES="" \
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

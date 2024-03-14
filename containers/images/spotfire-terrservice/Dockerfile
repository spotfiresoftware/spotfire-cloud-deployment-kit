ARG SPOTFIRE_NODEMANAGER_IMAGE_TAG
ARG SPOTFIRE_TERRSERVICE_VERSION

#
# extract Spotfire TERR service from sdn distribution file
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG} as extract

ENV TSNM_CAPABILITY=TERR

RUN mkdir -p /tmp/nodemanager-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/nodemanager-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN bash /opt/spotfire/nodemanager/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/nodemanager-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-terrservice specific
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG}

ARG SPOTFIRE_TERRSERVICE_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-terrservice" \
    org.opencontainers.image.description="Spotfire® Enterprise Runtime for R - Server Edition is a high-performance, enterprise-quality statistical engine to provide predictive analytic capabilities" \
    org.opencontainers.image.version="${SPOTFIRE_TERRSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Enterprise Runtime for R - Server Edition" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV TSNM_CAPABILITY=TERR

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y libtinfo5 \
  && apt-get clean all

COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/services /opt/spotfire/nodemanager/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/config/default.conf /opt/spotfire/nodemanager/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-terr.sh ./

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties

USER spotfire

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2

CMD ["./entrypoint-terr.sh"]

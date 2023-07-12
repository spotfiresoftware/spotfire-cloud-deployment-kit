ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION
ARG SPOTFIRE_TERRSERVICE_VERSION

#
# extract Spotfire TERR service from sdn distribution file
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID} as extract

ENV TSNM_CAPABILITY=TERR

RUN mkdir -p /tmp/tsnm-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/tsnm-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-terrservice specific
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

ARG SPOTFIRE_TERRSERVICE_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-terrservice" \
    org.opencontainers.image.description="TIBCO® Enterprise Runtime for R (TERR) Server Edition is a high-performance, enterprise-quality statistical engine to provide predictive analytic capabilities" \
    org.opencontainers.image.version="${SPOTFIRE_TERRSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO® Enterprise Runtime for R - Server Edition" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV TSNM_CAPABILITY=TERR

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get clean all

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-terr.sh ./

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties 

USER spotfire

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2

ENTRYPOINT ["./entrypoint-terr.sh"]

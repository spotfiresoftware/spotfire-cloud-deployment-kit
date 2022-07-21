ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION
ARG SPOTFIRE_TERRSERVICE_VERSION

#
# extract Spotfire TERR service from sdn distribution file
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID} as extract

RUN mkdir -p /tmp/tsnm-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability=TERR \
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
    org.opencontainers.image.vendor='TIBCO Software Inc.' \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.licenses='TIBCO EULA' \
    com.tibco.image.product.name="TIBCO Spotfire® Statistics Services" \
    com.tibco.image.component.name="TIBCO® Enterprise Runtime for R - Server Edition" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-license-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get clean all

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf

COPY custom.properties /tmp/custom.properties
RUN cat /tmp/custom.properties >> /opt/tibco/tsnm/nm/services/TERR/conf/custom.properties

USER spotfire

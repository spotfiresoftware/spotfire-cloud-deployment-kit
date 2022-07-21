ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NETCORE_VERSION

#
# extract Spotfire Automation Services service from sdn distribution file
#
FROM tibco/spotfire-workerhost:${SPOTFIRE_NETCORE_VERSION}-${IMAGE_BUILD_ID} as extract

RUN mkdir -p /tmp/tsnm-packages

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability=AUTOMATION_SERVICES \
    --framework=NETCORE \
    --directory=/tmp/tsnm-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-automationservices specific
#
FROM tibco/spotfire-workerhost:${SPOTFIRE_NETCORE_VERSION}-${IMAGE_BUILD_ID}

ARG SPOTFIRE_NETCORE_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-automationservices" \
    org.opencontainers.image.description="TIBCO Spotfire® Automation Services is a service for automatically executing multi-step jobs within your TIBCO Spotfire® environment." \
    org.opencontainers.image.version="${SPOTFIRE_NETCORE_VERSION}" \
    org.opencontainers.image.vendor='TIBCO Software Inc.' \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.licenses='TIBCO EULA' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® Automation Services" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-license-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf

USER spotfire

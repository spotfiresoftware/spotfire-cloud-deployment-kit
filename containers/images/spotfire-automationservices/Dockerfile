# check=skip=InvalidDefaultArgInFrom;error=true

ARG SPOTFIRE_WORKERHOST_IMAGE_TAG
ARG SPOTFIRE_NETCORE_VERSION

#
# extract Spotfire Automation Services service from sdn distribution file
#
FROM spotfire/spotfire-workerhost:${SPOTFIRE_WORKERHOST_IMAGE_TAG} AS extract

RUN mkdir -p /tmp/nodemanager-packages

ENV TSNM_CAPABILITY=AUTOMATION_SERVICES

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/nodemanager-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN bash /opt/spotfire/nodemanager/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --framework=NETCORE \
    --directory=/tmp/nodemanager-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-automationservices specific
#
FROM spotfire/spotfire-workerhost:${SPOTFIRE_WORKERHOST_IMAGE_TAG}

ARG SPOTFIRE_NETCORE_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-automationservices" \
    org.opencontainers.image.description="Spotfire® Automation Services is a service for automatically executing multi-step jobs within your Spotfire® environment." \
    org.opencontainers.image.version="${SPOTFIRE_NETCORE_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Automation Services" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

ENV TSNM_CAPABILITY=AUTOMATION_SERVICES

COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/services /opt/spotfire/nodemanager/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/config/default.conf /opt/spotfire/nodemanager/nm/config/default.conf

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2
RUN cp "nm/services/${TSNM_CAPABILITY}/log4net.config" log4net.config.orig \
    && sed -i 's~<maxSizeRollBackups value=".*" />~<maxSizeRollBackups value="${LOGGING_SERVICELOG_MAX}" />~g' "nm/services/${TSNM_CAPABILITY}/log4net.config" \
    && ! cmp "nm/services/${TSNM_CAPABILITY}/log4net.config" log4net.config.orig \
    && cp "nm/services/${TSNM_CAPABILITY}/log4net.config" log4net.config.orig \
    && sed -i 's~<maximumFileSize value=".*" />~<maximumFileSize value="${LOGGING_SERVICELOG_SIZE}" />~g' "nm/services/${TSNM_CAPABILITY}/log4net.config" \
    && ! cmp "nm/services/${TSNM_CAPABILITY}/log4net.config" log4net.config.orig \
    && rm log4net.config.orig

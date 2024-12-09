# check=skip=InvalidDefaultArgInFrom;error=true
ARG SPOTFIRE_WORKERHOST_IMAGE_TAG
ARG SPOTFIRE_NETCORE_VERSION

#
# extract Spotfire Web Player service from sdn distribution file
#
FROM spotfire/spotfire-workerhost:${SPOTFIRE_WORKERHOST_IMAGE_TAG} AS extract
ARG SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION
ENV TSNM_CAPABILITY=WEB_PLAYER
RUN mkdir -p /tmp/nodemanager-packages

# Language packs
COPY --chown=spotfire:spotfire build/SPOT_sfire_server_${SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION}_languagepack-multi.zip /tmp
RUN unzip -q -u -j /tmp/SPOT_sfire_server_*_languagepack-multi.zip '**/*-netcore.sdn' -d /tmp/nodemanager-packages/

# Web Player and any additional packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/nodemanager-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN bash /opt/spotfire/nodemanager/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --framework=NETCORE \
    --directory=/tmp/nodemanager-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-webplayer specific
#
FROM spotfire/spotfire-workerhost:${SPOTFIRE_WORKERHOST_IMAGE_TAG}

ARG SPOTFIRE_NETCORE_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-webplayer" \
    org.opencontainers.image.description="Spotfire® Web Player is a remote application server to enable analysis consumption from web browser and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_NETCORE_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Web Player" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

ENV TSNM_CAPABILITY=WEB_PLAYER

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

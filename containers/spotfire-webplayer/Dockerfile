ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NETCORE_VERSION

#
# extract Spotfire Web Player service from sdn distribution file
#
FROM tibco/spotfire-workerhost:${SPOTFIRE_NETCORE_VERSION}-${IMAGE_BUILD_ID} as extract
ARG SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION
ARG LANGUAGES="de-DE es-ES fr-FR it-IT ja-JP ko-KR pt-BR ru-RU zh-CN"

RUN mkdir -p /tmp/tsnm-packages
COPY --chown=spotfire:spotfire build/TIB_sfire_server_${SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION}_languagepack-multi.zip /tmp
RUN echo "${LANGUAGES}" | xargs -n1 | xargs -I '{}' unzip -q -u -j /tmp/TIB_sfire_server_*_languagepack-multi.zip '{}/{}-netcore.sdn' -d /tmp/tsnm-packages/

ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability=WEB_PLAYER \
    --framework=NETCORE \
    --directory=/tmp/tsnm-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-webplayer specific
#
FROM tibco/spotfire-workerhost:${SPOTFIRE_NETCORE_VERSION}-${IMAGE_BUILD_ID}

ARG SPOTFIRE_NETCORE_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-webplayer" \
    org.opencontainers.image.description="TIBCO Spotfire® Web Player is a remote application server to enable analysis consumption from web browser and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_NETCORE_VERSION}" \
    org.opencontainers.image.vendor='TIBCO Software Inc.' \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.licenses='TIBCO EULA' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® Web Player" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-license-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf

USER spotfire

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2
RUN cp nm/services/WEB_PLAYER/log4net.config log4net.config.orig \
    && sed -i 's~<maxSizeRollBackups value=".*" />~<maxSizeRollBackups value="${LOGGING_SERVICELOG_MAX}" />~g' nm/services/WEB_PLAYER/log4net.config \
    && ! cmp nm/services/WEB_PLAYER/log4net.config log4net.config.orig \
    && cp nm/services/WEB_PLAYER/log4net.config log4net.config.orig \
    && sed -i 's~<maximumFileSize value=".*" />~<maximumFileSize value="${LOGGING_SERVICELOG_SIZE}" />~g' nm/services/WEB_PLAYER/log4net.config \
    && ! cmp nm/services/WEB_PLAYER/log4net.config log4net.config.orig \
    && rm log4net.config.orig
ARG IMAGE_BUILD_ID=latest
FROM spotfire/spotfire-base:${IMAGE_BUILD_ID} as extract
ARG SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION
ARG SPOTFIRE_DEPLOYMENT_VERSION

RUN mkdir -p /opt/spotfire/deployment-files

# Spotfire.Dxp.sdn
ADD build/Spotfire.Dxp.sdn /opt/spotfire/deployment-files
WORKDIR /opt/spotfire/deployment-files/

# Add language packs, excluding the *-netcore.sdn files
COPY --chown=spotfire:spotfire build/SPOT_sfire_server_${SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION}_languagepack-multi.zip /tmp
RUN unzip -q -u -j /tmp/SPOT_sfire_server_*_languagepack-multi.zip -d /opt/spotfire/deployment-files/ -x '*-netcore.sdn'

LABEL org.opencontainers.image.title="spotfire/deployment" \
    org.opencontainers.image.description="Spotfire® deployment packages helper." \
    org.opencontainers.image.version="${SPOTFIRE_DEPLOYMENT_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® deployment packages" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

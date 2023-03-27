ARG IMAGE_BUILD_ID=latest
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as extract

RUN mkdir -p /opt/tibco/deployment-files

# Spotfire.Dxp.sdn
ADD build/Spotfire.Dxp.sdn /opt/tibco/deployment-files
WORKDIR /opt/tibco/deployment-files/

# Add language packs, excluding the *-netcore.sdn files
COPY --chown=spotfire:spotfire build/TIB_sfire_server_*_languagepack-multi.zip /tmp
RUN unzip -q -u -j /tmp/TIB_sfire_server_*_languagepack-multi.zip -d /opt/tibco/deployment-files/ -x '*-netcore.sdn'

LABEL org.opencontainers.image.title="tibco/spotfire-deployment" \
    org.opencontainers.image.description="TIBCO Spotfire® deployment packages helper." \
    org.opencontainers.image.version="${SPOTFIRE_DEPLOYMENT_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® deployment packages" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

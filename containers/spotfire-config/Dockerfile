ARG IMAGE_BUILD_ID=latest

#
# extract Spotfire config-tool from tss package
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as extract

ARG SPOTFIRE_SERVER_VERSION
ADD build/tss-${SPOTFIRE_SERVER_VERSION}.x86_64.tar.gz /tmp
RUN java -jar /tmp/tss-${SPOTFIRE_SERVER_VERSION}.x86_64/tomcat/webapps/spotfire/tools/spotfireconfigtool.jar

#
# spotfire-config specific
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as spotfire-config

ARG SPOTFIRE_SERVER_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-config" \
    org.opencontainers.image.description="TIBCO Spotfire® Server configuration tool provides a command-line for Spotfire installation and administration." \
    org.opencontainers.image.version="${SPOTFIRE_SERVER_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® configuration tool" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

WORKDIR /opt/tibco/

COPY --from=extract --chown=spotfire:spotfire /tmp/tss-*.x86_64/tomcat/webapps/spotfire/tools/spotfireconfigtool spotfireconfigtool/
COPY --chown=spotfire:spotfire bootstrap.sh ./

ENV BOOTSTRAP_FILE=bootstrap.xml

# "toolLog" means log to file and "console" menas log to console
ENV LOG_APPENDER=toolLog

USER spotfire

# config.sh is a wrapper that enforces the End User Agreement, then calls the actual config tool
RUN mkdir -p /opt/tibco/bin
COPY --chown=spotfire:spotfire eua-check.sh /opt/tibco/bin/config.sh
ENV PATH=$PATH:/opt/tibco/bin
ENTRYPOINT ["config.sh"]

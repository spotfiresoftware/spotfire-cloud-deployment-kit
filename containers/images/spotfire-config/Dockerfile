ARG IMAGE_BUILD_ID=latest

#
# extract Spotfire config-tool from spotfireserver package
#
FROM spotfire/spotfire-base:${IMAGE_BUILD_ID} as extract

ARG SPOTFIRE_SERVER_VERSION
ADD build/spotfireserver-${SPOTFIRE_SERVER_VERSION}.x86_64.tar.gz /tmp
RUN java -jar /tmp/spotfireserver-${SPOTFIRE_SERVER_VERSION}.x86_64/tomcat/webapps/spotfire/tools/spotfireconfigtool.jar

#
# spotfire-config specific
#
FROM spotfire/spotfire-base:${IMAGE_BUILD_ID} as spotfire-config

ARG SPOTFIRE_SERVER_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-config" \
    org.opencontainers.image.description="Spotfire® Server configuration tool provides a command-line for Spotfire installation and administration." \
    org.opencontainers.image.version="${SPOTFIRE_SERVER_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® configuration tool" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

WORKDIR /opt/spotfire/

COPY --from=extract --chown=spotfire:spotfire /tmp/spotfireserver-*.x86_64/tomcat/webapps/spotfire/tools/spotfireconfigtool spotfireconfigtool/
COPY --chown=spotfire:spotfire bootstrap.sh ./

ENV BOOTSTRAP_FILE=bootstrap.xml

# "toolLog" means log to file and "console" menas log to console
ENV LOG_APPENDER=toolLog

USER spotfire

# config.sh is a wrapper that enforces the End User Agreement, then calls the actual config tool
RUN mkdir -p /opt/spotfire/bin
COPY --chown=spotfire:spotfire eua-check.sh /opt/spotfire/bin/config.sh
ENV PATH=$PATH:/opt/spotfire/bin
ENTRYPOINT ["config.sh"]

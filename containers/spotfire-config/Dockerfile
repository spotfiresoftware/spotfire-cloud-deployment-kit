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
    org.opencontainers.image.vendor='TIBCO Software Inc.' \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.licenses='TIBCO EULA' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® configuration tool" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-license-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

WORKDIR /opt/tibco/

COPY --from=extract --chown=spotfire:spotfire /tmp/tss-*.x86_64/tomcat/webapps/spotfire/tools/spotfireconfigtool spotfireconfigtool/
COPY --chown=spotfire:spotfire bootstrap.sh ./

ENV PATH=$PATH:/opt/tibco/spotfireconfigtool
ENV BOOTSTRAP_FILE=bootstrap.xml

# Logging - enable us of LOG_LEVEL environment variable and use LOG_APPENDER
ADD log4j2-tools.xml.loglevel.transformation.xml .
RUN config.sh apply-xdt-transformation --input-file=/opt/tibco/spotfireconfigtool/log4j2-tools.xml --transformation-file=log4j2-tools.xml.loglevel.transformation.xml \
  && sed -i 's/ref="toolLog"/ref="${env:LOG_APPENDER:-toolLog}"/' /opt/tibco/spotfireconfigtool/log4j2-tools.xml \
  && rm -r log4j2-tools.xml.loglevel.transformation.xml spotfireconfigtool/logs

# "toolLog" means log to file and "console" menas log to console
ENV LOG_APPENDER=toolLog

USER spotfire
ENTRYPOINT ["config.sh"]

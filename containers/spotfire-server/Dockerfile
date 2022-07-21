ARG IMAGE_BUILD_ID=latest

#
# extract Spotfire Server from tss package
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as extract

ARG SPOTFIRE_SERVER_VERSION
ADD build/tss-${SPOTFIRE_SERVER_VERSION}.x86_64.tar.gz /tmp
RUN rm -rf /tmp/tss-*.x86_64/jdk/

#
# spotfire-server specific
#
FROM tibco/spotfire-base:${IMAGE_BUILD_ID} as spotfire-server

ARG SPOTFIRE_SERVER_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-server" \
    org.opencontainers.image.description="TIBCO Spotfire® Server is the administrative center of the Spotfire environment." \
    org.opencontainers.image.version="${SPOTFIRE_SERVER_VERSION}" \
    org.opencontainers.image.vendor='TIBCO Software Inc.' \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.licenses='TIBCO EULA' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® Server" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-license-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

WORKDIR /opt/tibco

COPY --from=extract --chown=spotfire:spotfire /tmp/tss-*.x86_64 /opt/tibco/tss/
COPY --chown=spotfire:spotfire entrypoint.sh ./
COPY --chown=spotfire:spotfire scripts/ scripts/
COPY --chown=spotfire:spotfire config/ config/

# Environment
ENV PATH=$PATH:/opt/tibco/tss/tomcat/spotfire-bin/ \
  SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/ \
  STARTUPCHECK_TIMEOUT_SECONDS="60" \
  STARTUPCHECK_ADMIN_USER="N" \
  STARTUPCHECK_VALID_DEPLOYMENT="N" \
  SITE_NAME="Default" \
  CATALINA_INITIAL_HEAPSIZE="512M" \
  CATALINA_MAXIMUM_HEAPSIZE="1G" \
  CATALINA_OPTS="-Djava.net.preferIPv4Stack=true"

RUN /opt/tibco/tss/configure -s 8080 -b 9443 -r 9080

# Temporary workaround - these jars need to be loaded when logging starts
RUN cp /opt/tibco/tss/tomcat/webapps/spotfire/WEB-INF/lib/jackson*.jar /opt/tibco/tss/tomcat/spotfire-boot-lib/

EXPOSE 8080 9443 9080 9081 5701 5702 5703

USER spotfire

# Logging
RUN config.sh apply-xdt-transformation --input-file=/opt/tibco/tss/tomcat/spotfire-config/log4j2.xml --transformation-file=config/log4j2.xml.rolling.transformation.xml
CMD ["/opt/tibco/entrypoint.sh", "/opt/tibco/tss/tomcat/bin/catalina.sh", "run"]

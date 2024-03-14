ARG SPOTFIRE_BASE_IMAGE_TAG

#
# extract Spotfire Server from tss package
#
FROM spotfire/spotfire-base:${SPOTFIRE_BASE_IMAGE_TAG} as extract

ARG SPOTFIRE_SERVER_VERSION
ADD build/spotfireserver-${SPOTFIRE_SERVER_VERSION}.x86_64.tar.gz /tmp
RUN rm -rf /tmp/spotfireserver-*.x86_64/jdk/

#
# spotfire-server specific
#
FROM spotfire/spotfire-base:${SPOTFIRE_BASE_IMAGE_TAG} as spotfire-server

ARG SPOTFIRE_SERVER_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-server" \
    org.opencontainers.image.description="Spotfire® Server is the administrative center of the Spotfire environment." \
    org.opencontainers.image.version="${SPOTFIRE_SERVER_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Server" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

WORKDIR /opt/spotfire

COPY --from=extract --chown=spotfire:spotfire /tmp/spotfireserver-*.x86_64 /opt/spotfire/spotfireserver/
COPY --chown=spotfire:spotfire entrypoint.sh ./
COPY --chown=spotfire:spotfire scripts/ scripts/
COPY --chown=spotfire:spotfire config/ config/

# Environment
ENV PATH=$PATH:/opt/spotfire/spotfireserver/tomcat/spotfire-bin/ \
  SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/ \
  STARTUPCHECK_TIMEOUT_SECONDS="60" \
  STARTUPCHECK_ADMIN_USER="N" \
  STARTUPCHECK_VALID_DEPLOYMENT="N" \
  SITE_NAME="Default" \
  CATALINA_INITIAL_HEAPSIZE="512M" \
  CATALINA_MAXIMUM_HEAPSIZE="1G" \
  CATALINA_OPTS="-Djava.net.preferIPv4Stack=true"

RUN /opt/spotfire/spotfireserver/configure -s 8080 -b 9443 -r 9080

# Temporary workaround - these jars need to be loaded when logging starts
RUN cp /opt/spotfire/spotfireserver/tomcat/webapps/spotfire/WEB-INF/lib/jackson*.jar /opt/spotfire/spotfireserver/tomcat/spotfire-boot-lib/

EXPOSE 8080 9443 9080 9081 5701 5702 5703

USER spotfire

# Logging
RUN config.sh apply-xdt-transformation --input-file=/opt/spotfire/spotfireserver/tomcat/spotfire-config/log4j2.xml --transformation-file=config/log4j2.xml.rolling.transformation.xml
CMD ["/opt/spotfire/entrypoint.sh", "/opt/spotfire/spotfireserver/tomcat/bin/catalina.sh", "run"]

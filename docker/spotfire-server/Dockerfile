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

WORKDIR /opt/tibco

COPY --from=extract --chown=spotfire:spotfire /tmp/tss-*.x86_64 /opt/tibco/tss/
COPY --chown=spotfire:spotfire entrypoint.sh ./
COPY --chown=spotfire:spotfire scripts/ scripts/
COPY --chown=spotfire:spotfire config/ config/

# Environment
ENV PATH=$PATH:/opt/tibco/tss/tomcat/spotfire-bin/ \
  SPOTFIRE_JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ \
  SPOTFIREDB_AUTO_UPGRADE="N" \
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
RUN config.sh apply-xdt-transformation --input-file=/opt/tibco/tss/tomcat/spotfire-config/log4j2.xml --transformation-file=config/log4j2.xml.rolling.transformation.xml \
 && mv config/log4j2-custom.xml /opt/tibco/tss/tomcat/spotfire-config

CMD ["/opt/tibco/entrypoint.sh", "/opt/tibco/tss/tomcat/bin/catalina.sh", "run"]

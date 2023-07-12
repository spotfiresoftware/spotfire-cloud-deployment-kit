ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION
ARG SPOTFIRE_PYTHONSERVICE_VERSION

#
# extract Spotfire Python service from sdn distribution file
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID} as extract

ENV TSNM_CAPABILITY=PYTHON

RUN mkdir -p /tmp/tsnm-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/tsnm-packages \
    --directory-pattern=*.{sdn,spk}


#
# spotfire-pythonservice specific
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

ARG SPOTFIRE_PYTHONSERVICE_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-pythonservice" \
    org.opencontainers.image.description="TIBCO Spotfire® Service for Python provides remote execution of Python data functions for users from web client and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_PYTHONSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® Service for Python" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV TSNM_CAPABILITY=PYTHON

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  # Workaround for python module requiring libffi6
  && apt-get install -y --no-install-recommends wget ca-certificates \
  && wget http://mirrors.edge.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb -O libffi6_3.2.1-8_amd64.deb \
  && dpkg -i  libffi6_3.2.1-8_amd64.deb \
  && rm libffi6_3.2.1-8_amd64.deb \
  # end workaround
  && apt-get clean all

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-python.sh ./

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties

# Make the command 'python' available
ENV LD_LIBRARY_PATH=/opt/tibco/tsnm/nm/services/PYTHON/python/lib/
ENV PATH=$PATH:/opt/tibco/tsnm/nm/services/PYTHON/python/bin/

USER spotfire

ENTRYPOINT ["./entrypoint-python.sh"]

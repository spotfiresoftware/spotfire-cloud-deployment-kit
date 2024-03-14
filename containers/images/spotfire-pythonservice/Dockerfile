ARG SPOTFIRE_NODEMANAGER_IMAGE_TAG=1
ARG SPOTFIRE_PYTHONSERVICE_VERSION
ARG PYTHON_VERSION=3.11

#
# extract Spotfire Python service from sdn distribution file
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG} as extract

ENV TSNM_CAPABILITY=PYTHON

RUN mkdir -p /tmp/nodemanager-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/nodemanager-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN bash /opt/spotfire/nodemanager/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/nodemanager-packages \
    --directory-pattern=*.{sdn,spk}
#
# spotfire-pythonservice specific
#
ARG PYTHON_VERSION
# Remove everything except site-packages which might contain python packages from sdn/spk
RUN mv /tmp/nodemanager-install/nm/services/PYTHON/python/lib/python${PYTHON_VERSION}/site-packages/ /tmp \
    && rm -rf /tmp/nodemanager-install/nm/services/PYTHON/python \
    && mkdir -p /tmp/nodemanager-install/nm/services/PYTHON/python/python${PYTHON_VERSION}/ \
    && mv /tmp/site-packages /tmp/nodemanager-install/nm/services/PYTHON/python/python${PYTHON_VERSION}/
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG}

ARG SPOTFIRE_PYTHONSERVICE_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-pythonservice" \
    org.opencontainers.image.description="Spotfire® Service for Python provides remote execution of Python data functions for users from web client and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_PYTHONSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Service for Python" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

ENV TSNM_CAPABILITY=PYTHON

# Temporarilty change from spotfire to root in order to install python
USER root
ARG PYTHON_VERSION
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv \
  && apt-get clean all

# Set up a python venv for spotfire
ENV SPOTFIRE_PYTHON_HOME=/opt/python-env
RUN mkdir -p ${SPOTFIRE_PYTHON_HOME} \
  && chown spotfire:spotfire ${SPOTFIRE_PYTHON_HOME}
USER spotfire
RUN python${PYTHON_VERSION} -m venv ${SPOTFIRE_PYTHON_HOME} --upgrade-deps \
  && ${SPOTFIRE_PYTHON_HOME}/bin/python -m pip install spotfire

COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/services /opt/spotfire/nodemanager/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/config/default.conf /opt/spotfire/nodemanager/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-python.sh ./

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB
ENV LOGGING_SERVICELOG_MAX=2

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties

USER spotfire

CMD ["./entrypoint-python.sh"]

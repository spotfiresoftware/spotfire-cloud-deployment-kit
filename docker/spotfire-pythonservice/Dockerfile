ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION

#
# extract Spotfire Python service from sdn distribution file
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID} as extract

RUN mkdir -p /tmp/tsnm-packages

# Add build/*.spk as needed
ADD --chown=spotfire:spotfire build/*.sdn /tmp/tsnm-packages/

# Note: multiple --file arguments are allowed
RUN /opt/tibco/tsnm/scripts/install-service.sh \
  --capability=PYTHON \
  --file=/tmp/tsnm-packages/Spotfire.Dxp.PythonServiceLinux.sdn



#
# spotfire-pythonservice specific
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get clean all

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf

COPY custom.properties /tmp/custom.properties
RUN cat /tmp/custom.properties >> /opt/tibco/tsnm/nm/services/PYTHON/conf/custom.properties

USER spotfire

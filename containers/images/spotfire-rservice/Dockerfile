ARG SPOTFIRE_NODEMANAGER_IMAGE_TAG
ARG SPOTFIRE_RSERVICE_VERSION

#
# extract Spotfire R service from sdn distribution file
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG} as extract

ENV TSNM_CAPABILITY=R

RUN mkdir -p /tmp/nodemanager-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/nodemanager-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN bash /opt/spotfire/nodemanager/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/nodemanager-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-rservice specific
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_IMAGE_TAG}

ARG SPOTFIRE_RSERVICE_VERSION
LABEL org.opencontainers.image.title="spotfire/spotfire-rservice" \
    org.opencontainers.image.description="Spotfire® Service for R provides remote execution of R data functions for users from web client and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_RSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.spotfire.image.product.name="Spotfire® Server" \
    com.spotfire.image.component.name="Spotfire® Service for R" \
    com.spotfire.image.license.url='https://www.cloud.com/legal/terms' \
    com.spotfire.image.type="commercial" \
    com.spotfire.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV TSNM_CAPABILITY=R

ARG DEBIAN_FRONTEND=noninteractive  \
    R_APT_VERSION=4.3.* \
    R_APT_SUITE=bookworm-cran40/

RUN apt update \
    && apt install -y  \
       ca-certificates \
       gnupg \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' | tee /etc/apt/trusted.gpg.d/cran_debian_key.asc \
    && echo deb https://cloud.r-project.org/bin/linux/debian "${R_APT_SUITE}" > /etc/apt/sources.list.d/r-project.list \
    && apt update -y \
    && apt install -y --no-install-recommends \
        "r-base-core=${R_APT_VERSION}" \
        "r-base-dev=${R_APT_VERSION}" \
        "r-recommended=${R_APT_VERSION}" \
    && apt clean all \
    && R --quiet -e 'R.version'

# Install any additional packages, also /opt/packages (see packagePath) can be used for additional packages
COPY --chown=spotfire:spotfire additional-packages.txt /tmp
RUN R --quiet -e 'install.packages(readLines(file("/tmp/additional-packages.txt", "r")))' \
    && rm /tmp/additional-packages.txt

COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/services /opt/spotfire/nodemanager/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/nodemanager-install/nm/config/default.conf /opt/spotfire/nodemanager/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-r.sh ./

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB \
    LOGGING_SERVICELOG_MAX=2

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/spotfire/nodemanager/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties

USER spotfire

# Configure R
ENV R_HOME=/usr/lib/R

CMD ["./entrypoint-r.sh"]

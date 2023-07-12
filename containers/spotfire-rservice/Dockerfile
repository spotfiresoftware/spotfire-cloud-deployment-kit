ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION
ARG SPOTFIRE_RSERVICE_VERSION

#
# extract Spotfire R service from sdn distribution file
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID} as extract

ENV TSNM_CAPABILITY=R

RUN mkdir -p /tmp/tsnm-packages

# Spotfire distributions or packages
ADD --chown=spotfire:spotfire build/*.sdn build/*.spk /tmp/tsnm-packages/

# Note: multiple --file arguments can be used instead of --directory and --directory-pattern to only use specific files
RUN /opt/tibco/tsnm/scripts/install-service.sh \
    --capability="${TSNM_CAPABILITY}" \
    --directory=/tmp/tsnm-packages \
    --directory-pattern=*.{sdn,spk}

#
# spotfire-rservice specific
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

ARG SPOTFIRE_RSERVICE_VERSION
LABEL org.opencontainers.image.title="tibco/spotfire-rservice" \
    org.opencontainers.image.description="TIBCO Spotfire® Service for R provides remote execution of R data functions for users from web client and mobile devices." \
    org.opencontainers.image.version="${SPOTFIRE_RSERVICE_VERSION}" \
    org.opencontainers.image.url='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.documentation='https://docs.tibco.com/products/tibco-spotfire/' \
    org.opencontainers.image.source='https://github.com/TIBCO/Spotfire-cloud-deployment-kit' \
    org.opencontainers.image.vendor='Cloud Software Group, Inc.' \
    org.opencontainers.image.licenses='Cloud Software Group, Inc. End User Agreement' \
    com.tibco.image.product.name="TIBCO Spotfire® Server" \
    com.tibco.image.component.name="TIBCO Spotfire® Service for R" \
    com.tibco.image.license.url='https://terms.tibco.com/#end-user-agreement' \
    com.tibco.image.type="commercial" \
    com.tibco.image.distribution-scope="private"

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV TSNM_CAPABILITY=R

ARG DEBIAN_FRONTEND=noninteractive  \
    R_APT_VERSION=4.3.* \
    R_APT_SUITE=bullseye-cran40/

RUN apt update \
    # R for Debian https://cloud.r-project.org/bin/linux/debian
    && apt upgrade -y \
    && apt install -y  \
        ca-certificates \
        gnupg \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && echo deb https://cloud.r-project.org/bin/linux/debian "${R_APT_SUITE}" > /etc/apt/sources.list.d/r-project.list \
    && apt update -y \
    # # R 4.2 for Ubuntu https://cran.r-project.org/bin/linux/ubuntu/
    #     && apt upgrade -y \
    #     && apt install -y  \
    #         software-properties-common \
    #         dirmngr \
    #         ca-certificates \
    #         gnupg \
    #         wget \
    #     && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    #     && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    #
    # Install R
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

COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/services /opt/tibco/tsnm/nm/services
COPY --from=extract --chown=spotfire:spotfire /tmp/tsnm-install/nm/config/default.conf /opt/tibco/tsnm/nm/config/default.conf
COPY --chown=spotfire:spotfire entrypoint-r.sh ./

# Configure logging
ENV LOGGING_SERVICELOG_SIZE=10MB \
    LOGGING_SERVICELOG_MAX=2

# Configure default container properties
COPY --chown=spotfire:spotfire ./default-container.properties .
RUN cat default-container.properties >> "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && chown spotfire:spotfire "/opt/tibco/tsnm/nm/services/${TSNM_CAPABILITY}/conf/custom.properties" \
  && rm default-container.properties

USER spotfire

# Configure R
ENV R_HOME=/usr/lib/R

ENTRYPOINT ["./entrypoint-r.sh"]
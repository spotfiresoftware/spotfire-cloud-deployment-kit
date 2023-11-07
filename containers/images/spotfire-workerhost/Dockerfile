ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION

#
# spotfire-workerhost specific
#
FROM spotfire/spotfire-nodemanager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

# Reuses most labels from nodemanager
LABEL org.opencontainers.image.title="spotfire/spotfire-workerhost" \
    org.opencontainers.image.description="This container image is an extension of the Spotfire® node manager image with common software dependencies required by Spotfire services using .NET."

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  # From prerequisites-debian12.sh
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libexpat1 \
    libxcb1 \
    libxkbcommon0 \
    libdbus-1-3 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libtiff6 \
    libpng16-16 \
    libgif7 \
    libjpeg62-turbo \
    xvfb \
    xauth \
    fonts-liberation \
    unixodbc \
  # Extra fonts
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    fonts-roboto \
    fonts-unfonts-core \
  # Malloc
    libjemalloc2 \
    libtcmalloc-minimal4 \
  && apt-get clean all

# .NET Core runtime
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN apt-get install -y --no-install-recommends wget ca-certificates \
  && wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     apt-transport-https \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     aspnetcore-runtime-6.0 \
  && apt-get clean all

# Example Connector odbc drivers
ARG INSTALL_ODBC_DRIVERS=Y
ARG INSTALL_POSTGRES_DRIVER=Y
ARG INSTALL_MARIADB_DRIVER=Y

COPY --chown=spotfire:spotfire scripts/ ./scripts/
RUN scripts/install-odbc-drivers.sh

USER spotfire

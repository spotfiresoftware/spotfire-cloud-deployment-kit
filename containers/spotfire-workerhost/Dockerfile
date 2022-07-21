ARG IMAGE_BUILD_ID=latest
ARG SPOTFIRE_NODEMANAGER_VERSION

#
# spotfire-workerhost specific
#
FROM tibco/spotfire-node-manager:${SPOTFIRE_NODEMANAGER_VERSION}-${IMAGE_BUILD_ID}

# Reuses most labels from node-manager
LABEL org.opencontainers.image.title="tibco/spotfire-workerhost" \
    org.opencontainers.image.description="This container image is an extension of the TIBCO Spotfire® node manager image with common software dependencies required by TIBCO Spotfire services using .NET."

# Temporarilty change from spotfire to root in order to install additional packages
USER root

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    # CEF dependencies
    libxcomposite1 \
    libasound2 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgbm1 \
    libcups2 \
    libxdamage1 \
    libpango-1.0-0 \
    libxrandr2 \
    libxkbcommon0 \
    xvfb \
    xauth \
    # Fonts
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-ipafont-mincho \
    fonts-ipafont-gothic \
    fonts-liberation \
    fonts-unfonts-core \
    fonts-roboto \
    # Libgdiplus deps
    libcairo2 \
    libexif12 \
    libfontconfig1 \
    libgif7 \
    libglib2.0-0 \
    libharfbuzz0b \
    libjpeg62-turbo \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpng16-16 \
    libtiff5 \
    libx11-6 \
    # Connectors
    unixodbc \
  # .NET Core runtime
  && apt-get install -y --no-install-recommends wget ca-certificates \
  && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     apt-transport-https \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     aspnetcore-runtime-6.0 \
  # Cleanup
  && apt-get clean all

# Example Connector odbc drivers
ARG INSTALL_ODBC_DRIVERS=Y
ARG INSTALL_POSTGRES_DRIVER=Y
ARG INSTALL_MARIADB_DRIVER=Y

COPY --chown=spotfire:spotfire scripts/ ./scripts/
RUN scripts/install-odbc-drivers.sh

USER spotfire

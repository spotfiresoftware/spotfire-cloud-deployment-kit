# Pre-requisites: You must need to place your spk and sdn files in the custom-modules directory
# Build: docker build -t webplayer-custom-modules .

# Add the script to exract and its dependencies
FROM debian as extract
RUN apt-get update -y && apt-get install -y unzip cabextract libxml2-utils
COPY unpack-modules-from-spk-sdn.sh /

# All spk and sdn files are copied to /custom-modules
COPY custom-modules/ /custom-modules
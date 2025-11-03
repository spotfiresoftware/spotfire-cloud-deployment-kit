#!/usr/bin/env bash

set -o errexit

custom_ca_certs_dir="/usr/local/share/ca-certificates"
spotfire_ssl_cert_dir="/opt/spotfire/certs"

# Check if custom CA directory exists and has content
if [ -d "${custom_ca_certs_dir}" ] && [ "$(ls -A "${custom_ca_certs_dir}" 2>/dev/null)" ]; then
    echo "Found custom CA certificates, copying to ${spotfire_ssl_cert_dir}..."
    cp -r "${custom_ca_certs_dir}/." "${spotfire_ssl_cert_dir}/"
    
    # Count certificates for user feedback
    cert_count=$(find "${spotfire_ssl_cert_dir}" -iname "*.crt" -o -iname "*.pem" -o -iname "*.cer" | wc -l)
    echo "Copied ${cert_count} certificate file(s)"
    
    echo "Rehashing certificates..."
    openssl rehash "${spotfire_ssl_cert_dir}"
    echo "Custom CA configuration completed successfully."
else
    echo "No custom CA certificates found in ${custom_ca_certs_dir}, skipping custom CA configuration."
fi
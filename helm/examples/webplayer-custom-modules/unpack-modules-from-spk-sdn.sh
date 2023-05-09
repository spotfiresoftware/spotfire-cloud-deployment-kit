#!/bin/bash

# Exit on error, undefined variable or pipe failure.
set -euo pipefail

function print_usage() {
  echo "Usage: $0 <input file> [<input file> ...] <output directory>"
  echo ""
  echo "Unpacks SDN and SPK files in a suitable folder structure for Spotfire Web Player and Automation Services."
  echo "Requires: unzip, xmllint, cabextract"
  echo "Example: $0 my-custom-module.sdn my-custom-module.spk /tmp/my-custom-modules" 
}

# Check that all required commands are available.
for tool in unzip xmllint cabextract; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: $tool is required but not installed. Aborting."
    echo
    print_usage
    exit 1
  fi
done

# The last argument is the output directory.
# The first argument to second to last is the input files.
# Check if there are at least two arguments
if [ $# -lt 2 ]; then
  print_usage
  exit 1
fi
output_dir="${@: -1}"
input_files=("${@:1:${#@}-1}")

# output_dir must must either not exist or it must be a directory
if [ -e "${output_dir}" ] && [ ! -d "${output_dir}" ]; then
  echo "ERROR: Output directory '${output_dir}' is not a directory."
  exit 1
fi

function extract_file() {
  local sdn_or_spk=$1

  # Unzip the SDN/SPK file.
  unzip -d "${TMP_DIR}" "${sdn_or_spk}"

  # Unzip packages in separate folders per package for SDN files.
  if [[ "${sdn_or_spk}" =~ \.sdn$ ]]; then
    find "${TMP_DIR}" -name "*.zip" -exec unzip -d "{}.extracted" {} \;
  fi

  # Extract CAB or ZIP content.
  find "${TMP_DIR}" -name "module.xml" -print0 | while read -d $'\0' module_xml; do
    package_dir=$(dirname "${module_xml}")
    package_name=$(xmllint --xpath "/module/name/text()" "${module_xml}")
    version=$(xmllint --xpath "/module/version/text()" "${module_xml}")
    id=$(xmllint --xpath "/module/id/text()" "${module_xml}")
    package_path="${output_dir}/${package_name}_${version}"
    mkdir -p "${package_path}"

    if compgen -G "${package_dir}/Contents/*.zip" > /dev/null; then
      unzip -o -d "${package_path}" "${package_dir}/Contents/*.zip"
    fi

    if compgen -G "${package_dir}/Contents/*.cab" > /dev/null; then
      for cabfile in "${package_dir}/Contents/"*.cab; do
        cabextract -d "${package_path}" "${cabfile}"
      done
    fi
  done
}

# Create a a temporary directory for extracting files.
TMP_DIR=$(mktemp -d)
cleanup() {
    if [ ! -d "${TMP_DIR}" ]; then
        return
    fi
    echo "Cleaning up temporary directory ${TMP_DIR}"
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

# Extract all input files.
for input_file in "${input_files[@]}"; do

  if [[ ! "${input_file,,}" =~ \.(sdn|spk)$ ]]; then
    echo "Invalid extension for file '${input_file}'. Only SDN and SPK extensions are valid."
    exit 1
  fi

  if [ ! -f "${input_file}" ]; then
    echo "Input file '${input_file}' does not exist."
    exit 1
  fi

  extract_file "${input_file}"
  cleanup "${TMP_DIR}"
done

echo "Successfully extracted ${input_files[@]} to ${output_dir}"

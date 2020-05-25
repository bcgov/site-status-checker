#!/bin/sh -l
#%
#%   Reads a CSV file of websites and outputs their statuses into results.csv
#%
#%     [TIMEOUT=10] ./count.sh ./input.csv [./results.csv]
#%

# Specify halt conditions (errors, unsets, non-zero pipes), field separator and verbosity
#
set -euo pipefail
IFS=$'\n\t'
[ ! "${VERBOSE:-}" == "true" ] || set -x

# Variables - input, output and curl timeout
#
INPUT_CSV="${1}"
SAVE_OUT="${2:-./results.csv}"
TIMEOUT="${TIMEOUT:-15}"

# Clean up input - exclude ftp \\, remove http[s]:// and clip after , / # ? (
#
url_cleaner() {
    echo ${1} | sed \
        -e 's/^ftp:\/\/.*//g' \
        -e 's/^\\.*//g' \
        -e 's/^ht[t]p[s]\?:\/\///g' \
        -e 's/,*$//g' \
        -e 's/(.*$//g' \
        -e 's/?.*$//g' \
        -e 's/#.*$//g' \
        -e 's/\/*$//g'
}

# Return HTTP status code, Excluded or Unavailable
#
curl_runner() {
    TO_CURL=$(url_cleaner ${1})
    case ${TO_CURL} in
        "") echo "Excluded" ;;
        *)  curl -ILm "${TIMEOUT}" -s "${TO_CURL}" | grep HTTP | grep -Eo '[0-9]*' | tail -1 \
            || echo "Unavailable" ;;
    esac
}

# Curl sites, echoing and saving results
#
echo >"${SAVE_OUT}"
while read -r in; do
    echo "${in%,}, $(curl_runner ${in})" | tee -a "${SAVE_OUT}"
done <"${INPUT_CSV}"

# Summarize
#
echo -e "\n---\nSummary"
echo -e "  $(grep -cve '^\s*$' ${INPUT_CSV}) in / $(grep -cve '^\s*$' ${SAVE_OUT}) out \n"

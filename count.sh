#!/bin/sh -l
#%
#%   Reads a CSV file of websites and outputs their statuses into results.csv
#%
#%     [TIMEOUT=10] THIS_FILE ./input.csv [./results.csv]
#%

# Boilerplate - halt conditions (errors, unsets, non-zero pipes), verbosity and help (w/o params)
#
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x
(($#)) || { grep "^#%" ${0} | sed -e "s/^#%//g" -e "s|THIS_FILE|${0}|g"; exit; }

# Variables - input, output and curl timeout
#
INPUT_CSV="${1}"
SAVE_OUT="${2:-./results.csv}"
TIMEOUT="${TIMEOUT:-15}"
HEADER_IN="${HEADER_IN:-URL}"
HEADER_OUT="${HEADER_OUT:-Status}"

# Return first match in header or error and length+1 for appending
#
header_position() {
    i=1
    IFS=, read -a HEADERS <<< "$(head -1 "${INPUT_CSV}")"
    for h in "${HEADERS[@]}"; do
        if [ "${h}" == "${1}" ]; then
            echo "${i}"
            return 0
        fi
        ((i=i+1))
    done
    echo "${i}"
    return 1
}

# Clean up input - exclude ftp \\, remove http[s]:// and clip after , ( ? / space
#
url_cleaner() {
    echo ${1} | sed \
        -e 's/^[(ftp:)(\\)].*//g' \
        -e 's/^http[s]\?:\/\///g' \
        -e 's/[ ,\(?#\/].*$//g' 
}

# Return HTTP status code, Excluded (ftp://, \\) or Unavailable (timeout, error)
#
curl_runner() {
    TO_CURL=$(url_cleaner ${1})
    case ${TO_CURL} in
        "") echo "Excluded" ;;
        *)  curl -ILm "${TIMEOUT}" -s "${TO_CURL}" -k | grep HTTP | grep -Eo '[0-9]{3}' | tail -1 ||
                echo "Unavailable" ;;
    esac
}

# Curl sites and save results
#
echo | tee "${SAVE_OUT}"
while read -r in; do
    echo "${in%,}, $(curl_runner ${in})" | tee -a "${SAVE_OUT}"
done <"${INPUT_CSV}"

# Summarize
#
echo -e "\n$(grep -cve '^\s*$' ${INPUT_CSV}) in / $(grep -cve '^\s*$' ${SAVE_OUT}) out \n"

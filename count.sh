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
    i=0
    head -1 "${INPUT_CSV}" | tr "," "\n" | while IFS=, read -r h; do
        ((i=i+1))
        [ "${h}" != "${1}" ] || echo "${i}"
    done
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

# Find relative positions for input and output columns
#
INDEX_IN=$(header_position ${HEADER_IN})
INDEX_OUT=$(header_position ${HEADER_OUT})

# Curl sites and save results
#
head -1 "${INPUT_CSV}" | tee "${SAVE_OUT}"
sed 1d "${INPUT_CSV}" | while read -r line; do
    IFS=, c=($line)
    RESULT=$(curl_runner ${c[${INDEX_IN}-1]})
    IFS=' '
    echo $line | awk -F, -v OFS=, '{$'"${INDEX_OUT}"'="'"${RESULT}"'"; print}' | tee -a "${SAVE_OUT}"
done

# Summarize
#
echo -e "\n$(grep -cve '^\s*$' ${INPUT_CSV}) in / $(grep -cve '^\s*$' ${SAVE_OUT}) out \n"

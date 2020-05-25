#!/bin/sh -l
#%
#% HTTP Status Checker for CSV Files
#%
#%   Reads a CSV file of websites and outputs their statuses into results.csv
#%

# Specify halt conditions (errors, unsets, non-zero pipes), field separator and verbosity
#
set -euo pipefail
IFS=$'\n\t'
[ ! "${VERBOSE:-}" == "true" ] || set -x

# Input and output files
#
INPUT_CSV=${1}
SAVE_OUT=${2:-./results.csv}

# Config variables
#
TIMEOUT=5
KEYWORDS="
    200
    400
    403
    404
    503
    Unavailable
    Excluded
"

# Function - clean up input (exclude ftp, \\ and trim ,, /, #.*, ?.*, (.*)
#
url_cleaner() {
    echo ${1} | sed \
        -e 's/^ftp:\/\/.*//g' \
        -e 's/^\\.*//g' \
        -e 's/^ht[t]p[s]\?:\/\///g' \
        -e 's/,*$//g' \
        -e 's/ *(.*$//g' \
        -e 's/?.*$//g' \
        -e 's/#.*$//g' \
        -e 's/\/*$//g'
}

# Function - return HTTP code, Excluded or Unavailable, depending on parameter
#
curl_runner() {
    TO_CURL=$(url_cleaner ${1})
    case ${TO_CURL} in
        "") echo "Excluded" ;;
        *)  curl -ILm "${TIMEOUT}" -s "${TO_CURL}" | grep HTTP | grep -Eo '[0-9]*' | tail -1 \
            || echo "Unavailable" ;;
    esac
}

# Curl sites, store with results in CSV
#
echo >"${SAVE_OUT}"
while read -r in; do
    echo; echo "${in}"
    RESULT=$(curl_runner ${in})
    echo "${in%,}, ${RESULT}" >>"${SAVE_OUT}"
    echo "${RESULT}"
done <"${INPUT_CSV}"

# Tally results
#
echo -e "\n ---\nResults"
for k in $(echo "${KEYWORDS}" | sed 's/^[ \t]*//g'); do
    echo "  ${k}: $(grep "$k" $SAVE_OUT | wc -l)"
done

# Summarize
#
echo -e "\n ---\nSummary"
echo "  Received: $(grep -cve '^\s*$' "${INPUT_CSV}")"
echo "  Returned: $(grep -cve '^\s*$' "${SAVE_OUT}")"

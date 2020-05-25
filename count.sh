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
SAVE_OUT=./results.csv

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

# Function - curl cleaned urls and return results
#
curl_cases() {
    if [ -z "${1}" ]; then
        RESULT="Excluded"
    else
        RESULT=$(curl -ILm "${TIMEOUT}" --silent "$(url_cleaner ${1})" | grep HTTP) || \
            RESULT="Unavailable"
    fi
    echo "$(curl -ILm "${TIMEOUT}" --silent "${1}" | grep HTTP)" >> temp.out
    echo "${1} ${RESULT##*$'\n'}" >>"${SAVE_OUT}"
    echo "${RESULT}"
}

# Curl sites, keeping only last line of results
#
echo >"${SAVE_OUT}"
while read -r in; do
    echo; echo "${in}"
    RESULT=$(curl_cases ${in})
    echo "${RESULT##*$'\n'}"
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
echo "  Returned: $(grep -cve '^\s*$' "${INPUT_CSV}")"

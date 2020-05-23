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

# Function - clean up input (exclude ftp, \\ and trim #, ?, /, (, etc.)
#
url_cleaner() {
    echo ${1} | sed \
        -e 's/ftp:\/\/.*//g' \
        -e 's/\\.*//g' \
        -e 's/ht[t]p[s]\?:\/\///g' \
        -e 's/,*$//g' \
        -e 's/ *(.*//g' \
        -e 's/?.*//g' \
        -e 's/#.*//g' \
        -e 's/\/*$//g'
}

# Curl sites, keeping only last line of results
#
echo >"${SAVE_OUT}"
while read -r in; do
    echo; echo "${in}"
    CLEANED=$(url_cleaner ${in})
    if [ -z "${CLEANED}" ]; then
        RESULT="Excluded"
    else
        RESULT=$(curl -ILm "${TIMEOUT}" --silent "${CLEANED}" | grep HTTP) || \
            RESULT="Unavailable"
    fi
    echo "${RESULT##*$'\n'}"
    echo "${in}, ${RESULT##*$'\n'}" >>"${SAVE_OUT}"
done <"${INPUT_CSV}"

# Tally results
#
KEYWORDS=$(echo "${KEYWORDS}" | sed 's/^[ \t]*//g')
echo -e "\n ---\nResults"
for k in $KEYWORDS; do
    echo "  ${k}: $(grep "$k" $SAVE_OUT | wc -l)"
done

# Summarize
#
COUNT_INPUT_CSV=$(grep -cve '^\s*$' "${INPUT_CSV}")
COUNT_OUTPUT_CSV=$(grep -cve '^\s*$' "${INPUT_CSV}")
COUNT_MISSING=$((${COUNT_INPUT_CSV} - ${COUNT_OUTPUT_CSV}))
#
echo -e "\n ---\nSummary"
echo "  Received: ${COUNT_INPUT_CSV}"
echo "  Returned: ${COUNT_OUTPUT_CSV}"
echo "  Missing:  ${COUNT_MISSING}"
echo -e "\n"

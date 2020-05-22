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

# Input, output and temp files
#
INPUT_CSV=${1}
SAVE_OUT=./results.csv
TEMPFILE=/tmp/count.sh-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20).csv

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

# Function - clean up input
#
url_cleaner() {
    TO_RETURN=$(echo ${1} | sed \
        -e 's/ftp:\/\/.*//g' \
        -e 's/\\.*//g' \
        -e 's/ht[t]p[s]\?:\/\///g' \
        -e 's/,*$//g' \
        -e 's/ *(.*//g' \
        -e 's/?.*//g' \
        -e 's/#.*//g' \
        -e 's/\/*$//g' \
    )
    echo ${TO_RETURN}
}

# Curl sites, keeping only last line of results
#
echo >"${SAVE_OUT}"
while read s; do
    echo; echo "${s}"
    CLEANED=$(url_cleaner ${s})
    if [ -z "${CLEANED}" ]; then
        RESULT="Excluded"
    else
        RESULT=$(curl -ILm "${TIMEOUT}" --silent "${CLEANED}" | grep HTTP) || \
            RESULT="Unavailable"
    fi
    echo "${RESULT##*$'\n'}"
    echo "${s}, ${RESULT##*$'\n'}" >>"${SAVE_OUT}"
done <"${INPUT_CSV}"

# Tally results
#
KEYWORDS=$(echo "${KEYWORDS}" | sed 's/^[ \t]*//g')
echo -e "\n ---\nResults"
COUNT_TALLIED="0"
for k in $KEYWORDS; do
    TALLY_K=$(grep "$k" $SAVE_OUT | wc -l)|| true
    echo "  ${k}: ${TALLY_K}"
    COUNT_TALLIED=$((${COUNT_TALLIED} + ${TALLY_K}))
done

# Summarize
#
COUNT_INPUT_CSV=$(grep -cve '^\s*$' "${INPUT_CSV}")
COUNT_UNKNOWN=$((${COUNT_INPUT_CSV} - ${COUNT_TALLIED}))
#
echo -e "\n ---\nSummary"
echo "  Total input: ${COUNT_INPUT_CSV}"
echo "  Total returned: ${COUNT_TALLIED}"
echo "  Total difference: ${COUNT_UNKNOWN}"
echo -e "\n"

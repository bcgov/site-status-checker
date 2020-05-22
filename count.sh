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
TEMP_IN=/tmp/.count.sh-in.csv
SAVE_OUT=./results.csv

# Vars
#
TIMEOUT=5
KEYWORDS="
    200
    400
    403
    404
    503
    Unavailable
"

# Exclude disallowed (ftp:// and \\)
#
grep -vi -e "ftp://" -e "\\\\" "${INPUT_CSV}" >"${SAVE_OUT}"

# Clean up input
#
sed -i -e 's/ht[t]p[s]\?:\/\///g' "${SAVE_OUT}" # http[s]://
sed -i -e 's/,*$//g' "${SAVE_OUT}"              # ,$ (ending commas)
sed -i -e 's/ *(.*//g' "${SAVE_OUT}"            # Notes in brackets
sed -i -e 's/?.*//g' "${SAVE_OUT}"              # ?.* (trailing query strings)
sed -i -e 's/#.*//g' "${SAVE_OUT}"              # #.* (trailing hash fragments)
sed -i -e 's/\/*$//g' "${SAVE_OUT}"             # /$ (trailing slashes)

# Sort and remove duplicates
#
sort "${SAVE_OUT}" | uniq >"${TEMP_IN}"

# Curl sites, keeping only last line of results
#
echo >"${SAVE_OUT}"
while read s; do
    echo -e "\n${s}"
    RESULT=$(curl -ILm "${TIMEOUT}" --silent "${s}" | grep HTTP) || true
    [ $? -eq 0 ] || RESULT="Unavailable"
    echo "${RESULT##*$'\n'}"
    echo "${RESULT##*$'\n'}" >>"${SAVE_OUT}"
done <"${TEMP_IN}"

# Tally results
#
KEYWORDS=$(echo "${KEYWORDS}" | sed 's/^[ \t]*//g')
echo -e "\n ---\nResults"
COUNT_TALLIED="0"
for k in $KEYWORDS; do
    COUNT_K=$(grep "$k" $SAVE_OUT | wc -l)|| true
    echo "  ${k}: ${COUNT_K}"
    COUNT_TALLIED=$(expr ${COUNT_TALLIED} + ${COUNT_K})
done

# Summarize
#
COUNT_INPUT_CSV=$(grep -cve '^\s*$' "${INPUT_CSV}")
COUNT_PROCESSED=$(grep -cve '^\s*$' "${TEMP_IN}")
COUNT_EXCLUDED=$(expr ${COUNT_INPUT_CSV} - ${COUNT_PROCESSED})
COUNT_UNKNOWN=$(expr ${COUNT_PROCESSED} - ${COUNT_TALLIED})
#
echo -e "\n ---\nSummary"
echo "  Total Input: ${COUNT_INPUT_CSV}"
echo "  Total Processed: ${COUNT_PROCESSED}"
echo "  Excluded or Duplicated: ${COUNT_EXCLUDED}"
echo "  Total Unknown: ${COUNT_UNKNOWN}"
echo -e "\n"

# Cleanup
#
rm "${TEMP_IN}"

# TODO: Pastable results

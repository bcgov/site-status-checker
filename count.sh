#!/bin/sh -l
#%
#% HTTP Status Checker for CSV Files
#%
#%   Reads a CSV file of websites and outputs their statuses
#%

# Specify halt conditions (errors, unsets, non-zero pipes), field separator and verbosity
#
# set -euo pipefail
IFS=$'\n\t'
[ ! "${VERBOSE:-}" == "true" ] || set -x

# Input
#
INPUT_CSV=${1}

# Vars
#
TIMEOUT=5
KEYWORDS="
200 OK
400 Bad Request
403 Forbidden
404 Not Found
Timed Out or Unreachable
"

# Temp files
#
TEMP_IN=/tmp/.count.sh-in.csv
TEMP_OUT=/tmp/.count.sh-out.csv

# Exclude disallowed (ftp:// and \\)
#
grep -vi -e "ftp://" -e "\\\\" "${INPUT_CSV}" > "${TEMP_OUT}"

# Clean up input
#
sed -i -e 's/ht[t]p[s]\?:\/\///g' "${TEMP_OUT}"                                                   # http[s]://
sed -i -e 's/,*$//g' "${TEMP_OUT}"                                                        # ,$ (ending commas)
sed -i -e 's/ *(.*//g' "${TEMP_OUT}"                                                       # Notes in brackets
sed -i -e 's/?.*//g' "${TEMP_OUT}"                                              # ?.* (trailing query strings)
sed -i -e 's/#.*//g' "${TEMP_OUT}"                                             # #.* (trailing hash fragments)
sed -i -e 's/\/*$//g' "${TEMP_OUT}"                                                    # /$ (trailing slashes)

# Sort and remove duplicates
#
sort "${TEMP_OUT}" | uniq > "${TEMP_IN}"

# Curl sites, keeping only last line of results
#
echo > "${TEMP_OUT}"
while read s; do
    echo -e "\n${s}"
    RESULT=$(curl -ILm "${TIMEOUT}" --silent "${s}" | grep HTTP)
    [ $? -eq 0 ]|| RESULT="Timed Out or Unreachable"
    echo "${RESULT##*$}"
    echo "${RESULT##*$'\n'}" >> "${TEMP_OUT}"
done < "${TEMP_IN}"

# Tally results
#
echo -e "\n ---\nResults"
COUNT_TALLIED="0"
for k in $KEYWORDS; do
    COUNT_K=$(grep "$k" $TEMP_OUT | wc -l )
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
rm "${TEMP_IN}" "${TEMP_OUT}"

# TODO: Pastable results
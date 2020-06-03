#!/bin/sh -l
#%
#%   Reads a CSV file of websites (header=URL) and outputs their statuses (header=HTTP_STATUS)
#%
#%     [TIMEOUT=10] THIS_FILE.sh ./input.csv [./results.csv]
#%

# Boilerplate - halt conditions (errors, unsets, non-zero pipes), verbosity and help (w/o params)
#
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x
(($#)) || {
    grep "^#%" ${0} | sed -e "s/^#%//g" -e "s|THIS_FILE.sh|${0}|g"
    exit
}

# Variable defaults - can assign at runtime with VARIABLE=value
#
TIMEOUT="${TIMEOUT:-15}"
HEADER_IN="${HEADER_IN:-URL}"
HEADER_OUT="${HEADER_OUT:-HTTP_STATUS}"

# Variables - input, output files
#
INPUT_CSV="${1}"
SAVE_OUT="${2:-./results.csv}"

# Internal field separator is usually a comma for CSV files
#
IFS=','

# Receive (1) a comma separated string and (2) a string, return a position match
#
csvar_position() {
    echo "${1}" | awk -F, '{for(i=1;i<=NF;i++){
        if($i=="'"${2}"'") print i;
    }}'
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
    *) curl -ILm "${TIMEOUT}" -s "${TO_CURL}" -k | grep HTTP | grep -Eo '[0-9]{3}' | tail -1 ||
        echo "Unavailable" ;;
    esac
}

# Curl sites and save results
#
APPEND=0
HEADERS=$(head -1 "${INPUT_CSV}")
INDEX_IN=$(csvar_position "${HEADERS}" "${HEADER_IN}")
INDEX_OUT=$(csvar_position "${HEADERS}" "${HEADER_OUT}")
if [ -z "${INDEX_OUT}" ]; then
    APPEND=1
    HEADERS=$(echo "${HEADERS}","${HEADER_OUT}")
    INDEX_OUT=$(csvar_position "${HEADERS}" "${HEADER_OUT}")
fi
#
echo "${HEADERS}" | tee "${SAVE_OUT}"
sed 1d "${INPUT_CSV}" | while read -r line; do
    c=($line)
    RESULT=$(curl_runner ${c[${INDEX_IN} - 1]})
    if [ "${APPEND}" -eq 1 ]; then
        echo "${line}", "${RESULT}" | tee -a "${SAVE_OUT}"
    else
        echo "${line}" | awk -F',' -vOFS=',' '{
            $'"${INDEX_OUT}"'="'"${RESULT}"'"; print
        }' | tee -a "${SAVE_OUT}"
    fi
done

# Summarize
#
echo -e "\n$(grep -cve '^\s*$' ${INPUT_CSV}) in / $(grep -cve '^\s*$' ${SAVE_OUT}) out \n"

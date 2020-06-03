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

# Variables - input CSV, output CSV, curl timeout (seconds), input header and output header 
#
CSV_IN="${1}"
CSV_OUT="${2:-./results.csv}"
TIMEOUT="${TIMEOUT:-15}"
HEADER_IN="${HEADER_IN:-URL}"
HEADER_OUT="${HEADER_OUT:-HTTP_STATUS}"

# Internal field separator - comma separated values
#
IFS=','

# Return position of string in comma separated list
#   fn list string
#
csvar_position() {
    echo "${1}" | awk -F, '{for(i=1;i<=NF;i++){
        if($i=="'"${2}"'") print i;
    }}'
}

# Clean up input - exclude ftp \\, remove http[s]:// and clip after , ( ? / space
#   fn string
#
url_cleaner() {
    echo ${1} | sed \
        -e 's/^[(ftp:)(\\)].*//g' \
        -e 's/^http[s]\?:\/\///g' \
        -e 's/[ ,\(?#\/].*$//g'
}

# Return HTTP status code, Excluded (ftp://, \\) or Unavailable (timeout, error)
#   fn string
#
curl_runner() {
    CURL_URL=$(url_cleaner ${1})
    case ${CURL_URL} in
    "") echo "Excluded" ;;
    *) curl -ILm "${TIMEOUT}" -s "${CURL_URL}" -k | grep HTTP | grep -Eo '[0-9]{3}' | tail -1 ||
        echo "Unavailable" ;;
    esac
}

# Format output line, inserting or appending
#   fn cs_line index_in index_out
#
csrow_builder() {
    CS_CUT_LIST=(${1})
    CURL_RESULT=$(curl_runner ${CS_CUT_LIST[${2} - 1]})
    case ${3} in
    "") echo "${1}","${CURL_RESULT}" ;;
    *) echo "${1}" | awk -F',' -vOFS=',' '{
            $'"${3}"'="'"${CURL_RESULT}"'"; print
        }' ;;
    esac
}

# Header and in/out indexes, append column if output header not present
#
HEADERS=$(head -1 "${CSV_IN}")
INDEX_IN=$(csvar_position "${HEADERS}" "${HEADER_IN}")
INDEX_OUT=$(csvar_position "${HEADERS}" "${HEADER_OUT}")
[ ! -z "${INDEX_OUT}" ] || HEADERS="${HEADERS}","${HEADER_OUT}"

# Curl sites and save results
#
echo "${HEADERS}" | tee "${CSV_OUT}"
sed 1d "${CSV_IN}" | while read -r CSV_LINE_IN; do
    csrow_builder "${CSV_LINE_IN}" "${INDEX_IN}" "${INDEX_OUT}" | tee -a "${CSV_OUT}"
done

# Summarize
#
echo -e "\n$(grep -cve '^\s*$' ${CSV_IN}) in / $(grep -cve '^\s*$' ${CSV_OUT}) out \n"

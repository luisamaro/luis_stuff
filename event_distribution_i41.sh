#!/usr/bin/env bash

###########################################################################
# This script gives the message distribution for a range of dates by date #
# to outoput totals for that range pipe, the next line to the command     #
#   awk -F' ' '{ a[$1] += $2 } END { for (i in a) print i, a[i] }'        #
#                                                                         #
# Usage:                                                                  #
#                                                                         #
#   program -s <start_date> [-n <number_of_days>]                         #
#     Date format:                                                        #
#       YYYY-MM-DD for HDFS                                               #
#       YYYYMMDD for Mongo                                                #
#                                                                         #
# Script made by Luis Amaro - Exabeam                                     #
# AA <= i41                                                               #
#                                                                         #
###########################################################################

shopt -s extglob
source /opt/exabeam/bin/shell-environment.bash 2> /dev/null

HDFS_DATE="+%Y-%m-%d"
MONGO_DATE="+%Y%m%d"
HDFS_COMMAND_1="hdfs -text /opt/exabeam/data/input/"
HDFS_COMMAND_2="/*.msg.gz 2> /dev/null | awk -F, '/msgType/{i=index(\$1, \":\");m=substr(\$1, i+2, length(\$1)-i-2); ++c[m];} END{PROCINFO[\"sorted_in\"] = \"@val_num_desc\";for(j in c) print j, c[j]}'"
MONGO_COMMAND_1="mongo event_db --quiet --eval='db.events_"
MONGO_COMMAND_2=".aggregate({ \"\$match\": { \"b\": { \"\$ne\": null }}}, { \"\$group\": { \"_id\": { \"b\": \"\$b\"}, \"count\": { \"\$sum\": 1}}})' | awk -F' ' '{print \$7\" \"\$11\"\r\"}'"

# exit
exit_program() {
  [[ $1 -eq 0 ]] && usage
  [[ $1 -eq 1 ]] && echo -e "Please insert a date with -s option\n" && usage
  [[ $1 -eq 2 ]] && echo -e "Invalid date formate, use formats in usage\n" && usage
  [[ $1 -eq 3 ]] && echo -e "Date doesn't exist, please use an existing date\n" && usage
  [[ $1 -eq 4 ]] && echo -e "Invalid number of days, please use an integer\n" && usage
  [[ $1 -eq 5 ]] && echo -e "${PROGRAM} - Functionality not implemented yet!\n" && usage
  [[ $1 -gt 5 ]] && echo -e "Unspecified error\n" && usage
  exit "${1}"
}

# usage
usage() {
  echo -e "Usage: $(basename "${0}") -s <start_date> [-n <number_of_days>]"
  echo -e "Date format:\n  YYYY-MM-DD for HDFS\n  YYYYMMDD for Mongo\n"
}

# check date
check_date_format() {
  date "${2}" -d "${1}" > /dev/null 2>&1
  IS_VALID_DATE="${?}"
  [[ "${IS_VALID_DATE}" -ne 0 ]] && exit_program 3
}

# main program
main() {
  if [ -z "${3}" ]; then
    DAYS_TO_RUN=0
  else
    DAYS_TO_RUN=$(( "${3}" - 1 ))
  fi
  DAYS=0
  while [ "${DAYS_TO_RUN}" -ge 0 ]; do
    DATE_TO_RUN=$(date "${1}" -d "${2} + ${DAYS} days")
    echo -e "\nDAY: ${DATE_TO_RUN}"
    [[ "${PROGRAM}" == "hdfs" ]] && eval "${COMMAND_TO_RUN_1}${DATE_TO_RUN}${COMMAND_TO_RUN_2}"
    [[ "${PROGRAM}" == "mongo" ]] && eval "${COMMAND_TO_RUN_1}${DATE_TO_RUN}_m${COMMAND_TO_RUN_2} && ${COMMAND_TO_RUN_1}${DATE_TO_RUN}_s${COMMAND_TO_RUN_2}"
    DAYS=$(( DAYS + 1 )); DAYS_TO_RUN=$(( DAYS_TO_RUN - 1 ))
  done
  exit 0
}

# program arguments
while getopts ":s:n:h" ARG; do
  case "${ARG}" in
    s)
      START_DATE="${OPTARG}"
      ;;
    n)
      NUMBER_OF_DAYS="${OPTARG}"
      ;;
    h)
      exit_program 0
      ;;
    *)
      exit_program 1
      ;;
  esac
done
shift $((OPTIND-1))

# -s must exist
[[ -z "${START_DATE}" ]] && exit_program 1

# check date
if [[ "${START_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  PROGRAM="hdfs"
  DATE_FORMAT="${HDFS_DATE}"
  COMMAND_TO_RUN_1="${HDFS_COMMAND_1}"
  COMMAND_TO_RUN_2="${HDFS_COMMAND_2}"
elif [[ "${START_DATE}" =~ ^[0-9]{8}$ ]]; then
  PROGRAM="mongo"
  DATE_FORMAT="${MONGO_DATE}"
  COMMAND_TO_RUN_1="${MONGO_COMMAND_1}"
  COMMAND_TO_RUN_2="${MONGO_COMMAND_2}"
else
  exit_program 2
fi
check_date_format "${START_DATE}" "${DATE_FORMAT}"

#if -n exists make sure it is a number
if [[ -n "${NUMBER_OF_DAYS}" ]]; then
  # if it is not
  if ! [[ "${NUMBER_OF_DAYS}" =~ ^[0-9]+$ ]]; then
    exit_program 4
  else
    main "${DATE_FORMAT}" "${START_DATE}" "${NUMBER_OF_DAYS}"
  fi
else
  main "${DATE_FORMAT}" "${START_DATE}"
fi

exit_program 99

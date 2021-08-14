#!/usr/bin/env bash

usage()
{
  echo "Usage:"
  echo "  ${0} <-u|-d> <cloud_instanceID> <origin_folder> <destination_folder>"
  echo "  ${0} -h"
  exit 1
}

[[ $# -ne 4 ]] && usage

while getopts ":duh" ARGS; do
  case "${ARGS}" in
    d ) direction="download"
      ;;
    u ) direction="upload"
      ;;
    h ) usage
        quit 0
      ;;
    * ) echo "Invalid arguments"
        usage
        quit 1
      ;;
  esac
done
shift $(( OPTIND-1 )) # Shift option index back

[[ "${direction}" == "download" ]] && gcloud compute scp --project "ops-dist-${1}" "${1}-cli:/home/luis_exabeam_com/${2}" "${3}" && exit 0
[[ "${direction}" == "upload" ]] && gcloud compute scp --project "ops-dist-${1}" "${2}" "${1}-cli:/home/luis_exabeam_com/" && exit 0
exit 2

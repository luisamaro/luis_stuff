#!/usr/bin/env bash

usage()
{
  echo "Usage:"
  echo "  ${0} <-d|-u> <cloud_instanceID> <origin_folder> <destination_folder>"
  echo "  ${0} -h"
  exit 1
}
#
# MAIN
[[ $# -ne 4 ]] && usage
#
# GET COMMAND LINE OPTIONS
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
#
[[ "${direction}" == "download" ]] && rsync -e "gcloud compute ssh --project ops-dist-${1}" "luis@${1}-cli.ia.exabeam.com:/home/luis_exabeam_com/${2}" "${3}" && exit 0
[[ "${direction}" == "upload" ]] && rsync -e "gcloud compute ssh" "${2}" "luis@${1}-cli.ia.exabeam.com:/home/luis_exabeam_com/${3}" && exit 0
exit 2

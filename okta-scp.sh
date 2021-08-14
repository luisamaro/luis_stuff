#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  ${0} <-u|-d> <cloud_instanceID> <origin_folder> <destination_folder>"
  echo "  ${0} -h"
  exit 1
}
#
# MAIN
[[ "${#}" -ne 4 ]] && usage
#
# GET COMMAND LINE OPTIONS
while getopts ":d:uh" ARGS; do
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
[[ "${#}" -ne 3 ]] && usage
[[ "${direction}" == "download" ]] && scp "luis@${1}-cli.ia.exabeam.com:${2} ${3}" && exit 0
[[ "${direction}" == "upload" ]] && scp "${2} luis@${1}-cli.ia.exabeam.com:${3}" && exit 0
exit 2

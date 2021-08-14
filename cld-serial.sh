#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  ${0} <cloud instanceID> <vm>"
  echo "  ${0} -h"
  exit 1
}

[[ $# -ne 2 ]] && [[ $# -ne 3 ]] && usage
[[ "${1}" == "-h" ]] && usage
[[ $# -eq 2 ]] && PORT="1"
[[ $# -eq 3 ]] && PORT="${3}"
gcloud compute --project="${1}" instances get-serial-port-output "${2}" --port="${PORT}" && exit 0
exit 2

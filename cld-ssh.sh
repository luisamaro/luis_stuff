#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  $0 <cloud instanceID>"
  echo "  $0 -h"
  exit 1
}


[[ $# -ne 1 ]] && usage
[[ "${1}" == "-h" ]] && usage
gcloud compute ssh "${1}-cli" --project "ops-dist-${1}" --ssh-key-file=~/.ssh/exabeam_gcloud --ssh-flag="-A" --ssh-flag="-o TCPKeepAlive=true" && exit 0
exit 2

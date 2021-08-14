#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  $0 <cloud instanceID>"
  exit 1
}

[[ $# -ne 1 ]] && usage
gcloud compute instances list --project "ops-dist-${1}" && exit 0
exit 2


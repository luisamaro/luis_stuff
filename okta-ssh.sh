#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  $0 <cloud instanceID>"
  exit 1
}

[[ $# -ne 1 ]] && usage
ssh -o "TCPKeepAlive=true" "luis@${1}-cli.ia.exabeam.com" && exit 0
exit 2

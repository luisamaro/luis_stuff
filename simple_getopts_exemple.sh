#!/usr/bin/env bash

# This script does nothing


usage() { echo "Usage: $0 [-s <45|90>] [-e <string>]" 1>&2; exit 1; }

while getopts ":s:e:" ARG; do
    case "${ARG}" in
        s)
            s=${OPTARG}
            ((s == 45 || s == 90)) || usage
            ;;
        e)
            e=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${e}" ]; then
    usage
fi

echo "s = ${s}"
echo "e = ${e}"

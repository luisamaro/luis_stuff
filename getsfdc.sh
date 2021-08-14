#!/usr/bin/env bash
#
# QUIT
quit()
{
  if [[ -z "${1}" ]]; then
    echo "Unknown error :(No error code)"
  elif [[ "${1}" -ne 0 ]]; then
    if [[ "${1}" -eq 2 ]]; then
      echo "File ${FILENAME} already exists in ~/work/${CASE}/ :$1"
    elif [[ "${1}" -eq 3 ]]; then
      echo "Folder $(echo "${FILENAME}" | cut -d '.' -f 1) already exists in ~/work/${CASE}/ :$1"
    elif [[ "${1}" -eq 4 ]]; then
      echo "File not compressed or unknown compress format :$1"
    else
      echo "Unknown error :${1}"
    fi
  fi
  exit "${1}"
}
#
# USAGE
usage()
{
  echo "Usage:"
  echo -e "$(basename "${0}") -c <case#> -u \"<url>\" [-f] [-e] [-p <bar|dot>]\n"
  echo -e "Get support files from Salesfoce.com cases\n"
  echo "optional arguments:"
  echo "     -p <bar|dot>                                             :Define progress type(optional)"
  echo "     -h                                                       :Help"
  echo "     -f                                                       :Delete existing files/folders and recreate them"
  echo "     -e                                                       :Don't extract downloaded file"
}
#
# UNCOMPRESS FILE IF COMPRESSED FORMAT
uncompress_file()
{
  cd ~/work/"${CASE}" > /dev/null || exit 4
  if [[ $(echo "${FILENAME}" | rev | cut -d "." -f 1 | rev) == "tar"  ]]; then
    tar xf "${FILENAME}" && rm "${FILENAME}"
  elif [[ "$(echo "${FILENAME}" | rev | cut -d "." -f 1,2 | rev)" == "tar.gz"  ]]; then
    tar zxf "${FILENAME}" && rm "${FILENAME}"
  elif [[ $(echo "${FILENAME}" | rev | cut -d "." -f 1,2 | rev) == "tar.bz2"  ]]; then
    tar jxf "${FILENAME}" && rm "${FILENAME}"
  elif [[ $(echo "${FILENAME}" | rev | cut -d "." -f 1,2 | rev) == "tar.xz"  ]]; then
    tar xf "${FILENAME}" && rm "${FILENAME}"
  elif [[ $(echo "${FILENAME}" | rev | cut -d "." -f 1 | rev) == "gz"  ]]; then
    gunzip "${FILENAME}" && rm "${FILENAME}"
  elif [[ $(echo "${FILENAME}" | rev | cut -d "." -f 1 | rev) == "zip"  ]]; then
    unzip "${FILENAME}" && rm "${FILENAME}"
    [[ -n $(ls -1 -- *.tar.gz 2> /dev/null) ]] && for TARGZ in *.tar.gz; do tar zxf "${TARGZ}"; done
  else
    cd - > /dev/null || exit 4
    quit 4
  fi
  cd - > /dev/null || exit 4
  quit 0
}
#
# GET FILE FROM SALESFORCE
get_file()
{
  ! wget -q --progress="${PROGRESS}" --show-progress --no-check-certificate -O ~/work/"${CASE}/${FILENAME}" "${URL}" && echo "wget: Error getting file" && quit 1
  return 0
}
#
# GET COMMAND LINE OPTIONS
while getopts ":p:c:u:feh" ARGS; do
  case "${ARGS}" in
    p ) PROGRESS="${OPTARG}"
      ;;
    c ) CASE="${OPTARG}"
      ;;
    u ) URL="${OPTARG}"
      ;;
    f ) FORCE=" "
      ;;
    e ) DONT_EXTRACT=" "
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
[[ -z "${PROGRESS}" ]] && PROGRESS="bar:mega"
[[ -n "${PROGRESS}" ]] && PROGRESS="${PROGRESS}:mega"
#
if [[ -z "${CASE}" ]] || [[ -z "${URL}" ]]; then
  echo "Please provide a case number and URL for file. Progress type is optional"
  usage
  quit 1
fi
#
# GET FILENAME FROM URL
FILENAME=$(basename "$(echo "${URL}" | cut -d '?' -f 1)")
#
# GET FOLER NAME FROM FILENAME
FOLDER=$( echo "${FILENAME}" | cut -d '.' -f 1 )

[[ -n "${FORCE}" ]] && rm -rf ~/work/"${CASE}"
if [[ ! -d ~/work/"${CASE}" ]] > /dev/null; then  # If case folder doesn't exist
  mkdir -p ~/work/"${CASE}" > /dev/null && get_file && [[ -z "${DONT_EXTRACT}" ]] && uncompress_file # Create case folder, get files and uncompress them
else
  if [[ ! -f ~/work/"${CASE}"/"${FOLDER}" ]] > /dev/null; then # If case file folder doesn't exist
    if [[ ! -f ~/work/"${CASE}"/"${FILENAME}" ]] > /dev/null; then # If case folder exists and case file doesn't
      get_file && [[ -z "${DONT_EXTRACT}" ]] && uncompress_file
    else
      [[ -z "${DONT_EXTRACT}" ]] && uncompress_file # Otherwise just try to uncompress it
    fi
  fi
fi
quit 0

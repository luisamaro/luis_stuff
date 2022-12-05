# simple script to pull/update all repos

#! /usr/bin/env bash

WORKING_FOLDER=$(pwd)
BLUE='\033[0;34m'
CIAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NOCOLOR='\033[0m'

for FOLDER in $(ls -1d -- *)
do
  [[ -d "${FOLDER}" ]] && \
  [[ -d "${FOLDER}/.git" ]] && \
  echo -e "\n${CIAN}Repo: ${BLUE}${FOLDER}${NOCOLOR}" && \
  echo -e "${CIAN}Branch: ${BLUE}$(awk -F/ '{print $3}' ${FOLDER}/.git/HEAD)${NOCOLOR}" && \
  cd "${FOLDER}" && \
  git pull
  cd "${WORKING_FOLDER}"
done

echo -e "\n${YELLOW}Happy pulling${NOCOLOR}"

#!/bin/bash

CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BLACK='\033[0;30m'

t_flag=0
o_flag=0
r_flag=0

help () {
  printf "${CYAN}GitHub Exporter\n"
  printf "${BLACK}command options are:\n"
  printf "${CYAN}-h: help\n"
  printf "-t: token\n"
  printf "-o: organization\n"
  printf "-r: repo list, one repo per line text file\n"
  printf "-l: lock the repo(s)\n"
}

LOCK="false"

while getopts ":ht:o:r:l" opt; do
  case ${opt} in
    h)
      help
      ;;
    t)
      GITHUB_TOKEN=${OPTARG}
      t_flag=1
      ;;
    o)
      ORG=${OPTARG}
      o_flag=1
      ;;
    r)
      INPUT=$(realpath "${OPTARG}")
      r_flag=1
      ;;
    l)
      LOCK="true"
      ;;
    \?)
      echo "${RED}Invalid option: ${OPTARG}${BLACK}"
      help
      exit 1
      ;;
    :)
      echo "${RED}Invalid option: ${OPTARG} requires an argument${BLACK}" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [[ $t_flag -eq 0 ]] || [[ $o_flag -eq 0 ]] || [[ $r_flag -eq 0 ]]
then
  echo "${RED}You must use [-t] [-o] and [-r]${BLACK}"
  help
  exit 1
fi

repo_list () {
  while read -r line; do
    echo -n ""${ORG}"/"${line}"\",\""
  done < "${INPUT}"
}

REPO_LIST="\"$(repo_list | sed 's/","$//')\""
STATE="started"

if [ $LOCK = "true" ]; then
  echo "${RED}Locking repos${BLACK}"
else
  echo "${RED}Migrating without locking repos${BLACK}"
fi

printf "${CYAN}Exporting ${REPO_LIST}${BLACK}\n"

MIGRATION_URL=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  -X POST \
  -H "Accept: application/vnd.github.wyandotte-preview+json" \
  -d "{\"lock_repositories\":${LOCK},\"repositories\":[$REPO_LIST]}" \
  https://api.github.com/orgs/$ORG/migrations | \
  jq '.url' | sed 's/"//g')

echo "${CYAN}Migration URL: ${MIGRATION_URL}${BLACK}"

i=0
dots=...
while [ $STATE != "exported" ]; do
  STATE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.wyandotte-preview+json" \
    $MIGRATION_URL | \
    jq '.state' | sed 's/"//g')
  if [ $i -eq 0 ]; then
    echo "${CYAN}Migration state: ${STATE}${dots}${BLACK}"
  elif [ ${STATE} != "exported" ] && [ $i -ne 0 ]; then
    echo -e

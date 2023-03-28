#!/bin/bash

CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BLACK='\033[0;30m'

t_flag=0
o_flag=0
r_flag=0

halp () {
  printf "GitHub Exporter\n"
  printf "command options are:\n"
  printf "h: help\n"
  printf "t: token\n"
  printf "o: organization\n"
  printf "r: repo list, one repo per line text file\n"
  printf "l: lock the repo(s)\n"
}

LOCK="false"

while getopts ":ht:o:r:l" opt; do
  case ${opt} in
    h) 
      halp
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
    \?) echo "Usage: export.sh [-h] [-t] [-o] [-r]"
        echo "Use -h for help"
      ;;
    :) 
      echo "Invalid option: ${OPTARG} requires and argument" 1>&2
      ;;
  esac
done 
shift $((OPTIND -1))

if [[ $t_flag -eq 0 ]] || [[ o_flag -eq 0 ]] || [[ r_flag -eq 0 ]]
then
  halp
  echo -e "${RED}You must use [-t] [-o] and [-r]"
  tput sgr0
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
  echo -e "${RED}Locking repos"
else
  echo -e "${RED}Migrating without locking repos"
fi
tput sgr0

printf "Exporting ${REPO_LIST}\n"

MIGRATION_URL=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  -X POST \
  -H "Accept: application/vnd.github.wyandotte-preview+json" \
  -d "{\"lock_repositories\":${LOCK},\"repositories\":[$REPO_LIST]}" \
  https://api.github.com/orgs/$ORG/migrations | \
  jq '.url' | sed 's/"//g')

echo -e "Migration URL: ${CYAN}${MIGRATION_URL}"
tput sgr0

i=0
dots=...
while [ $STATE != "exported" ]; do
  STATE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.wyandotte-preview+json" \
    $MIGRATION_URL | \
    jq '.state' | sed 's/"//g')
  if [ $i -eq 0 ]; then
    echo "Migration state: ${STATE}${dots}"
  elif [ ${STATE} != "exported" ] && [ $i -ne 0 ]; then
    echo -e "\e[1A\e[KMigration state: ${STATE}${dots}"
  fi
  let i++
  dots="$dots."
  sleep 2
done

k="Migration state: exporting"
for i in ${#k}; do
  echo -e "\e[1A\e[K${k::-$i}\|${dots}"
  sleep .05
done
echo -e "\e[1A\e[KCOMPLETE"

ARCHIVE_URL=`curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.wyandotte-preview+json" \
  ${MIGRATION_URL}/archive`

curl -s "${ARCHIVE_URL}" -o "${ORG}"_archive.tar.gz

archive=$(ls -lh | grep "${ORG}"_archive.tar.gz | awk '{print $9" "$5}')

echo -e "Output ${BLUE}${archive}"
tput sgr0

exit 0
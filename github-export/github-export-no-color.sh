#!/bin/bash

t_flag=0
o_flag=0
r_flag=0

help () {
  printf "GitHub Exporter\n"
  printf "command options are:\n"
  printf "-h: help\n"
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
      echo "Invalid option: ${OPTARG}"
      help
      exit 1
      ;;
    :)
      echo "Invalid option: ${OPTARG} requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [[ $t_flag -eq 0 ]] || [[ $o_flag -eq 0 ]] || [[ $r_flag -eq 0 ]]
then
  echo "You must use [-t] [-o] and [-r]"
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
  echo "Locking repos"
else
  echo "Migrating without locking repos"
fi

printf "Exporting ${REPO_LIST}\n"

MIGRATION_URL=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  -X POST \
  -H "Accept: application/vnd.github.wyandotte-preview+json" \
  -d "{\"lock_repositories\":${LOCK},\"repositories\":[$REPO_LIST]}" \
  https://api.github.com/orgs/$ORG/migrations | \
  jq '.url' | sed 's/"//g')

echo "Migration URL: ${MIGRATION_URL}"

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
    echo -e "\rMigration state: ${STATE}${dots}"
  fi
  let i++
  dots="$dots."
  sleep 2
done

k="Migration state: exporting"
for i in ${#k}; do
  echo -e "\r${k::-$i}\|${dots}"
  sleep .05
done
echo -e "\rCOMPLETE"

ARCHIVE_URL=`curl -s -H "Authorization:
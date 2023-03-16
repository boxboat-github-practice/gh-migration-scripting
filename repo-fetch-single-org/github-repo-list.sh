#!/bin/bash

# Replace these values with your actual organization name and GitHub token
ORG="your_organization_name"
GHTOKEN="your_github_token"

# Function to retrieve the repository names from a single page
function get_repo_names_from_page {
  RESPONSE=$(curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GHTOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/${ORG}/repos?page=${1}")

  # Check for errors in the response
  if [ "$(echo "${RESPONSE}" | jq -r 'type')" = "object" ] && [ "$(echo "${RESPONSE}" | jq -r '.message')" = "Bad credentials" ]; then
    echo "Error: Invalid GitHub token"
    exit 1
  elif [ "$(echo "${RESPONSE}" | jq -r 'type')" = "object" ] && [ "$(echo "${RESPONSE}" | jq -r '.message')" = "Not Found" ]; then
    echo "Error: Invalid organization name"
    exit 1
  elif [ "$(echo "${RESPONSE}" | jq -r 'type')" = "array" ] && [ "$(echo "${RESPONSE}" | jq -r '.[].name')" = "null" ]; then
    echo "Error: No repositories found for page ${1}"
    exit 1
  else
    echo "${RESPONSE}" | jq -r '.[].name'
  fi
}

# Retrieve the repository names from all pages
REPO_NAMES=()
PAGE=1

while true; do
  PAGE_REPO_NAMES=$(get_repo_names_from_page "${PAGE}")

  if [ -n "${PAGE_REPO_NAMES}" ]; then
    REPO_NAMES+=(${PAGE_REPO_NAMES})
    PAGE=$((PAGE+1))
  else
    break
  fi
done

# Write the repository names to a file
if [ ${#REPO_NAMES[@]} -gt 0 ]; then
  printf '%s\n' "${REPO_NAMES[@]}" > repo-listing.txt
  echo "Repository names saved to repo-listing.txt"
else
  echo "Error: No repositories found"
  exit 1
fi

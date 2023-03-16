#!/bin/bash

# Define variables
ORG=<your_organization>
GHTOKEN=<your_github_token>

# Check if jq is installed
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is not installed. Please install jq and try again."
  exit 1
fi

# Validate input
if [ -z "$ORG" ]; then
  echo "Error: Organization name is not set. Please set the 'ORG' variable in the script."
  exit 1
fi

if [ -z "$GHTOKEN" ]; then
  echo "Error: GitHub token is not set. Please set the 'GHTOKEN' variable in the script."
  exit 1
fi

# Get all members within an org and put their logins into members-listing.txt (overwrites file)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GHTOKEN}"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/orgs/$ORG/members | jq -r '.[].login' > members-listing.txt

# Get all org members emails contained within members-listing.txt and insert into email-listing.txt (requires starting from a clean file)
> email-listing.txt
while IFS= read -r line; do
  user_data=$(curl -s -H "Authorization: Bearer ${GHTOKEN}" https://api.github.com/users/$line)

  if ! echo "$user_data" | jq -e '.email' > /dev/null; then
    echo "Warning: Failed to fetch user data for $line."
    echo "" >> email-listing.txt
    continue
  fi

  echo "$user_data" | jq -r '.email' >> email-listing.txt
done < members-listing.txt

# Combine members-listing.txt and email-listing.txt into member-email-listing.txt
paste -d, members-listing.txt email-listing.txt > member-email-listing.txt
echo "Success: Member and email data combined into member-email-listing.txt"

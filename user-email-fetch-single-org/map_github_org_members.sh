#!/bin/bash

# Check if jq is installed
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is not installed. Please install jq and try again."
  exit 1
fi

# Define variables
ORG1=boxboat-demo
ORG2=boxboat-demo
GHTOKEN1=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
GHTOKEN2=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

# Validate input
if [ -z "$ORG1" ] || [ -z "$ORG2" ]; then
  echo "Error: One or both organization names are not set. Please set the 'ORG1' and 'ORG2' variables in the script."
  exit 1
fi

if [ -z "$GHTOKEN1" ] || [ -z "$GHTOKEN2" ]; then
  echo "Error: One or both GitHub tokens are not set. Please set the 'GHTOKEN1' and 'GHTOKEN2' variables in the script."
  exit 1
fi

function fetch_members() {
  org=$1
  token=$2
  members_file=$3
  emails_file=$4

  # Get all members within an org and put their logins into members_file (overwrites file)
  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${token}"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/$org/members | jq -r '.[].login' > "$members_file"

  # Get all org members emails contained within members_file and insert into emails_file (requires starting from a clean file)
  > "$emails_file"
  while IFS= read -r line; do
    user_data=$(curl -s -H "Authorization: Bearer ${token}" https://api.github.com/users/$line)

    if ! echo "$user_data" | jq -e '.email' > /dev/null; then
      echo "Warning: Failed to fetch user data for $line."
      echo "" >> "$emails_file"
      continue
    fi

    echo "$user_data" | jq -r '.email' >> "$emails_file"
  done < "$members_file"
}

# Fetch members for both organizations
fetch_members "$ORG1" "$GHTOKEN1" "members-listing-1.txt" "email-listing-1.txt"
fetch_members "$ORG2" "$GHTOKEN2" "members-listing-2.txt" "email-listing-2.txt"

# Combine members and emails into member-email-listing files
paste -d, "members-listing-1.txt" "email-listing-1.txt" > "member-email-listing-1.csv"
paste -d, "members-listing-2.txt" "email-listing-2.txt" > "member-email-listing-2.csv"

# Compare members based on email addresses and save results into common_members.csv
awk -F, 'NR==FNR{a[$2]=$1;next} ($2 in a){print a[$2]","$2","$1}' "member-email-listing-1.csv" "member-email-listing-2.csv" > "common_members.csv"
echo "Success: Common members data saved into common_members.csv"

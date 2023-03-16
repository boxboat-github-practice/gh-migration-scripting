# GitHub Organization Members Email Extractor

This script retrieves the usernames and email addresses of members in a GitHub organization and saves them in a comma-separated values (CSV) format. It is useful for generating a list of organization members' emails for further processing or communication purposes.

## Requirements

- `curl`: Command-line tool for making HTTP requests
- `jq`: Lightweight and flexible command-line JSON processor

To install the requirements on a Debian-based system, run:

```
sudo apt-get update
sudo apt-get install curl jq
```

On other systems, refer to their respective package managers or the official documentation of `curl` and `jq`.

## Setup

1. Open the script `get_github_members_emails.sh` in a text editor.
2. Replace `<your_organization>` with your actual GitHub organization name.
3. Replace `<your_github_token>` with your actual GitHub token. The token should have the `read:org` scope for public organizations or `admin:org` for private organizations.

## Usage

1. Give execute permissions to the script:

```
chmod +x get_github_members_emails.sh
```

2. Run the script:

```
./get_github_members_emails.sh
```

The script will generate three files:

- `members-listing.txt`: Contains the usernames of the organization members.
- `email-listing.txt`: Contains the email addresses of the organization members.
- `member-email-listing.txt`: Contains the usernames and email addresses of the organization members, separated by a comma.

## Important Note

Please be aware that not all users have public email addresses on their GitHub profiles. This script will only be able to retrieve email addresses that are publicly available.

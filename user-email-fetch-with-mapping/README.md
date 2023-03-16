# GitHub Organization Members Email Extractor and Mapper

This script retrieves the usernames and email addresses of members in two GitHub organizations and saves them in a comma-separated values (CSV) format. It then compares/maps the members based on their email addresses and outputs a list of common members. This is useful for identifying members who are part of both organizations.

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

1. Open the script `map_github_org_members.sh` in a text editor.
2. Replace `<your_organization_1>` and `<your_organization_2>` with your actual GitHub organization names.
3. Replace `<your_github_token_1>` and `<your_github_token_2>` with your actual GitHub tokens. The tokens should have the `read:org` scope for public organizations or `admin:org` for private organizations.

## Usage

1. Give execute permissions to the script:

```chmod +x map_github_org_members.sh```

2. Run the script:

```./map_github_org_members.sh```

The script will generate the following files:

- `members-listing-1.txt`: Contains the usernames of the first organization's members.
- `members-listing-2.txt`: Contains the usernames of the second organization's members.
- `email-listing-1.txt`: Contains the email addresses of the first organization's members.
- `email-listing-2.txt`: Contains the email addresses of the second organization's members.
- `member-email-listing-1.csv`: Contains the usernames and email addresses of the first organization's members.
- `member-email-listing-2.csv`: Contains the usernames and email addresses of the second organization's members.
- `common_members.csv`: Contains the usernames and email addresses of common members between the two organizations, separated by a comma.

## Important Note

Please be aware that not all users have public email addresses on their GitHub profiles. This script will only be able to retrieve email addresses that are publicly available if used with public organizations.

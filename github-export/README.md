# GitHub Exporter

The `github-exporter.sh` script allows you to export multiple repositories from a GitHub organization. It is designed to work with GitHub's migration API and will export all branches, tags, issues, pull requests, and wiki pages for each repository.

## Requirements

- `curl`
- `jq`

## Usage

To use this script, you need to provide the following command line options:

- `-t`: Your GitHub API access token. This token should have permission to read and write your organization's repositories.
- `-o`: The name of the GitHub organization from which to export repositories.
- `-r`: The path to a text file containing the list of repositories to export. Each line in the file should contain the name of one repository.
- `-l`: (Optional) Lock the repositories to prevent new commits during the migration.

### Example usage

```./github-exporter.sh -t YOUR_GITHUB_TOKEN -o YOUR_ORGANIZATION_NAME -r /path/to/repo-listing.txt -l```

## What is exported

This script will export the following for each repository:

- All branches
- All tags
- All issues and their associated comments
- All pull requests and their associated comments
- All wiki pages

## What is not exported

This script will not export the following:

- Deploy keys or Secrets
- Collaborators
- Settings (including webhooks and branch protections)
- Issues or pull requests that are locked or private
- Releases and Packages

## How it works

1. The script reads in the command line options and checks to make sure all required options are present.
2. The script reads in the list of repositories from the input file and generates a comma-separated list of repository names in the format required by the GitHub migration API.
3. The script uses the GitHub migration API to start a new migration job for the specified repositories. If the `-l` option is used, the script will lock the repositories before starting the migration.
4. The script polls the migration API every 2 seconds to check the status of the migration job. Once the migration is complete, the script continues to poll the API until the job has been fully exported.
5. Once the job has been fully exported, the script downloads the resulting archive file from the migration API and saves it to the current directory.

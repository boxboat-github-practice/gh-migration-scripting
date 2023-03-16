# GitHub Organization Repository Listing Script

This bash script retrieves a list of all repository names in a specified GitHub organization and saves them to a file named `repo-listing.txt`.

## Prerequisites

- Bash shell
- curl
- jq
- A GitHub personal access token with the `repo` scope

## Instructions

1. Replace `your_organization_name` and `your_github_token` in the script with your actual organization name and GitHub token.

2. Make the script executable by running the following command:

```chmod +x github-repo-list.sh```

3. Run the script by typing the following command in the terminal:

```./github-repo-list.sh```

4. If the script runs successfully, a message will be displayed indicating that the repository names have been saved to `repo-listing.txt`.

## Additional Information

- The script uses the GitHub API to retrieve a list of repository names from the specified organization. The `curl` command is used to make the API request, and the `jq` command is used to parse the JSON response.

- The script retrieves all pages of repositories returned by the API. If no repositories are found, an error message will be displayed.

- The script includes error handling for invalid organization names and GitHub tokens. If an error occurs, the script will exit with an error message.

- The script requires a GitHub personal access token with the `repo` scope. You can create a new token in your GitHub account settings. Be sure to keep your token secret, as it provides access to your GitHub account.

- This script is provided as-is, without warranty or support. Use at your own risk.

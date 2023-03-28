# Migrating Organizations from GitHub.com to GitHub Enterprise Cloud

You can migrate organizations from GitHub.com to GitHub Enterprise Cloud using the GitHub Enterprise Importer. You can run the migration using the GitHub CLI or the API. This README.md represents a consolidated form of Official GitHub documentation found at [Migrate Organizations](https://docs.github.com/en/migrations/using-github-enterprise-importer/migrating-organizations-with-github-enterprise-importer/migrating-organizations-from-githubcom-to-github-enterprise-cloud) & [Reclaim Mannequins](https://docs.github.com/en/migrations/using-github-enterprise-importer/completing-your-migration-with-github-enterprise-importer/reclaiming-mannequins-for-github-enterprise-importer)

## About organization migrations with GitHub Enterprise Importer

The GitHub CLI simplifies the migration process and is recommended for most customers. Advanced customers with heavy customization needs can use the API to build their own integrations with GitHub Enterprise Importer.

## Prerequisites

- You must be an organization owner or have the migrator role in the source organization.
- You must be an enterprise owner in the destination enterprise account.
- You must have created personal access tokens that can access the source organization and destination enterprise and set them as environment variables.

## Step 1: Install and Upgrade the GEI extension of the GitHub CLI

If this is your first migration, you'll need to install the GEI extension of the GitHub CLI.

1. Install the GitHub CLI. You need version 2.4.0 or newer of GitHub CLI.
2. Install the GEI extension using the following command:

```
gh extension install github/gh-gei
```

3. Update the GEI extension of the GitHub CLI. The GEI extension is updated weekly. To make sure you're using the latest version, update the extension using the following command:

```
gh extension upgrade github/gh-gei
```

## Step 2: Set environment variables

Before you can use the GEI extension to migrate to GitHub Enterprise Cloud, you must create personal access tokens that can access the source organization and target enterprise, then set the personal access tokens (classic) as environment variables.

1. Create and record a personal access token that meets all the scope requirements (Repo & Admin:Org) to authenticate for the source organization for organization migrations. 
2. Create and record a personal access token that meets all the scope requirements () to authenticate for the target enterprise for organization migrations.
3. Set environment variables for the personal access tokens, replacing TOKEN in the commands below with the personal access tokens (classic) you recorded above. Use GH_PAT for the target enterprise and GH_SOURCE_PAT for the source organization. If you're using Terminal, use the export command:

```
export GH_PAT="TOKEN"
export GH_SOURCE_PAT="TOKEN"
```

## Step 3: Migrate your organization

To migrate an organization, use the `gh gei migrate-org` command, replacing the placeholders in the command below with the following values:

- `SOURCE`: Name of the source organization
- `DESTINATION`: The name you want the new organization to have. Must be unique on GitHub.com.
- `ENTERPRISE`: The slug for your destination enterprise, which you can identify by looking at the URL for your enterprise account, https://github.com/enterprises/SLUG.

```
gh gei migrate-org --github-source-org SOURCE --github-target-org DESTINATION --github-target-enterprise ENTERPRISE --wait
```

## Step 4: Validate your migration and check the error log

After your migration has finished, check the migration log repository for any errors or issues that need to be addressed. We also recommend performing a soundness check of your organization and migrated repositories.

## Step 5: Reclaim mannequins for GitHub Enterprise Importer

To reclaim mannequins with the GitHub CLI, use the following commands:

1. Generate a CSV file with a list of mannequins for an organization:
```
gh gei generate-mannequin-csv --github-target-org DESTINATION --output FILENAME.csv
```

Edit the CSV file, adding the username of the organization member that corresponds to each mannequin.

2. Reclaim mannequins in bulk with the mapping file you created earlier:
```
gh gei reclaim-mannequin --github-target-org DESTINATION --csv FILENAME.csv
```

*Note that commit authorship is not associated with mannequins and cannot be attributed to GitHub users by reclaiming mannequins. Instead, commit authorship is attributed to user accounts on GitHub based on the email address that was used to author the commit in Git.
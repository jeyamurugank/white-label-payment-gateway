
#!/usr/bin/env bash
set -euo pipefail
# Requires: gh CLI authenticated with repo:admin scope

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
REVIEWERS="${2:-"team:platform,team:security"}" # comma-separated "user:alice,team:platform"

echo "Setting up environments for $REPO"

# Create environments if not exist
gh api --method PUT repos/$REPO/environments/staging > /dev/null || true
gh api --method PUT repos/$REPO/environments/production > /dev/null || true

# Configure protection rules (manual reviewers) - GitHub API for environment protection
read -r -d '' BODY <<JSON
{
  "wait_timer": 0,
  "reviewers": [
    { "type": "Team", "id": 1 },
    { "type": "Team", "id": 2 }
  ],
  "deployment_branch_policy": { "protected_branches": true, "custom_branch_policies": false }
}
JSON

# Note: You must replace reviewer team IDs with real IDs:
# gh api orgs/<org>/teams/<team> to fetch id.
echo "$BODY" | gh api   --method PUT   -H "Accept: application/vnd.github+json"   repos/$REPO/environments/production/protection -F data=@-

echo "Production environment protected. Update team IDs as needed."

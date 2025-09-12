#!/usr/bin/env bash
set -euo pipefail

# This script prunes Gitea repositories, keeping only the allowed ones.
# It requires Gitea admin credentials or a token with repo admin permissions.
#
# Environment variables you must set:
#   GITEA_BASE_URL   e.g. http://localhost:3000
#   GITEA_TOKEN      Personal access token
#   GITEA_OWNER      Organization or user that owns the repos (e.g. cloud-native)
#
# Repositories to keep (exact names)
ALLOWED_REPOS=("infra" "rust-api")

if [[ -z "${GITEA_BASE_URL:-}" || -z "${GITEA_TOKEN:-}" || -z "${GITEA_OWNER:-}" ]]; then
  echo "ERROR: Please export GITEA_BASE_URL, GITEA_TOKEN, and GITEA_OWNER." >&2
  exit 1
fi

header() {
  echo "[gitea-prune] $*"
}

is_allowed() {
  local name="$1"
  for repo in "${ALLOWED_REPOS[@]}"; do
    if [[ "$repo" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

API="$GITEA_BASE_URL/api/v1"
AUTH_HEADER="Authorization: token $GITEA_TOKEN"

header "Listing repositories for owner '$GITEA_OWNER'..."
# Paginate just in case. Fetch first 5 pages of 50 each (adjust as needed)
repos_json=$(\
  { for page in 1 2 3 4 5; do \
      curl -fsSL -H "$AUTH_HEADER" "$API/orgs/$GITEA_OWNER/repos?page=$page&limit=50" || \
      curl -fsSL -H "$AUTH_HEADER" "$API/users/$GITEA_OWNER/repos?page=$page&limit=50"; \
    done; } | jq -s 'flatten')

count=$(echo "$repos_json" | jq 'length')
header "Found $count repositories."

to_delete=( )
for row in $(echo "$repos_json" | jq -r '.[] | @base64'); do
  _jq() { echo "$row" | base64 -d | jq -r "$1"; }
  name=$(_jq '.name')
  full_name=$(_jq '.full_name')
  if is_allowed "$name"; then
    header "Keeping: $full_name"
  else
    to_delete+=("$name")
  fi
done

if [[ ${#to_delete[@]} -eq 0 ]]; then
  header "Nothing to delete."
  exit 0
fi

header "Will delete: ${to_delete[*]}"

for name in "${to_delete[@]}"; do
  url="$API/repos/$GITEA_OWNER/$name"
  header "Deleting $GITEA_OWNER/$name ..."
  curl -fsS -X DELETE -H "$AUTH_HEADER" "$url" >/dev/null && header "Deleted $name" || {
    echo "Failed to delete $name" >&2
  }
done

header "Done."



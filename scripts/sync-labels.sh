#!/usr/bin/env bash
# Sync a consistent label set across every repo in the echoforge-games org.
#
# Idempotent. Uses `gh label create --force` which creates the label if
# missing and updates its color/description if it already exists.
#
# The label set is the union of:
#   - The CLAUDE.md convention (bug, critical, enhancement,
#     in-progress, qa-ready, verified, found-by-claude, qa-found,
#     user-reported, discord-reported)
#   - The org issue-template labels (feature, task)
#
# Requires:
#   - gh CLI authenticated with `repo` scope
#   - Org admin (or write) access to every echoforge-games repo
#
# Usage:
#   bash scripts/sync-labels.sh                # sync every org repo
#   bash scripts/sync-labels.sh repo-a repo-b  # sync only the named repos

set -euo pipefail

OWNER="echoforge-games"

# Format: NAME|COLOR|DESCRIPTION  (one per array entry)
LABELS=(
  "bug|d73a4a|Something is broken or behaving wrong"
  "critical|b60205|Drop-everything severity"
  "feature|a2eeef|New functionality or meaningful enhancement"
  "task|cfd3d7|Chore, infra, content update"
  "enhancement|a2eeef|Improvement to existing functionality"
  "in-progress|fbca04|Someone is actively working on this"
  "qa-ready|0e8a16|Implementation done, ready for QA verification"
  "verified|0075ca|QA-verified and closed"
  "found-by-claude|8a2be2|Surfaced by a Claude session"
  "qa-found|d4c5f9|Surfaced during QA"
  "user-reported|c5def5|Reported by an end user"
  "discord-reported|5865f2|Filed via Discord (Fig bot or manual)"
)

# Pick repo list: explicit args, or all org repos.
if (( $# > 0 )); then
  REPOS=("$@")
else
  mapfile -t REPOS < <(
    gh repo list "$OWNER" --limit 200 --json name --jq '.[].name'
  )
fi

echo ">> Syncing ${#LABELS[@]} labels across ${#REPOS[@]} repos in $OWNER..."

failures=0
for repo in "${REPOS[@]}"; do
  printf '\n[%s]\n' "$repo"
  for spec in "${LABELS[@]}"; do
    IFS='|' read -r name color desc <<<"$spec"
    if gh label create "$name" \
        --color "$color" \
        --description "$desc" \
        --repo "$OWNER/$repo" \
        --force >/dev/null 2>&1; then
      printf '  ok  %s\n' "$name"
    else
      printf '  FAIL %s\n' "$name"
      failures=$((failures + 1))
    fi
  done
done

echo ""
echo ">> Done. Failures: $failures"
exit $(( failures > 0 ? 1 : 0 ))

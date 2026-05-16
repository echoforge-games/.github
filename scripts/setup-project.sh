#!/usr/bin/env bash
# Set up the EchoForge org-level GitHub Project "EchoForge - All Work".
#
# Idempotent: re-running this skips anything that already exists. Safe to
# run again after a partial failure.
#
# Requires:
#   - gh CLI authenticated (org admin)
#   - Token scopes: project, read:org, repo
#
# Note: uses `gh --jq` (gojq, bundled with gh) so no external `jq` needed.
#
# What this does:
#   1. Creates the org-level Project "EchoForge - All Work" (if missing).
#   2. Adds custom fields: Surface, Arcade Game, Area, Priority, Iteration.
#
# What this does NOT do (do these in the UI; see notes at end of run):
#   - Rename / re-option the default Status field
#     (single-select options can't be edited via API once created).
#   - Create saved views.
#   - Configure org-level Issue Types.
#   - Link repos to the Project (template at bottom of file).

set -euo pipefail

OWNER="echoforge-games"
TITLE="EchoForge - All Work"

# ---------------------------------------------------------------------------
# 1. Find or create the Project
# ---------------------------------------------------------------------------
echo ">> Looking up existing project on org '$OWNER'..."
PROJECT_NUMBER="$(
  gh project list --owner "$OWNER" --format json \
    --jq ".projects[] | select(.title == \"$TITLE\") | .number"
)"

if [[ -z "${PROJECT_NUMBER:-}" ]]; then
  echo ">> Creating project '$TITLE'..."
  PROJECT_NUMBER="$(
    gh project create --owner "$OWNER" --title "$TITLE" \
      --format json --jq '.number'
  )"
  echo ">> Created project #$PROJECT_NUMBER"
else
  echo ">> Project already exists as #$PROJECT_NUMBER"
fi

PROJECT_URL="$(
  gh project view "$PROJECT_NUMBER" --owner "$OWNER" \
    --format json --jq '.url'
)"
PROJECT_NODE_ID="$(
  gh project view "$PROJECT_NUMBER" --owner "$OWNER" \
    --format json --jq '.id'
)"
echo ">> Project URL: $PROJECT_URL"

# ---------------------------------------------------------------------------
# 2. Add custom fields (skip any that already exist by name)
# ---------------------------------------------------------------------------
existing_field_names() {
  gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" \
    --format json --jq '.fields[].name'
}

field_exists() {
  local name="$1"
  existing_field_names | grep -Fxq "$name"
}

create_single_select() {
  local name="$1"
  local options="$2"
  if field_exists "$name"; then
    echo "   - [$name] exists, skipping"
    return
  fi
  echo "   - Creating single-select field [$name]"
  gh project field-create "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --name "$name" \
    --data-type SINGLE_SELECT \
    --single-select-options "$options" >/dev/null
}

create_text() {
  local name="$1"
  if field_exists "$name"; then
    echo "   - [$name] exists, skipping"
    return
  fi
  echo "   - Creating text field [$name]"
  gh project field-create "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --name "$name" \
    --data-type TEXT >/dev/null
}

# ITERATION isn't supported by `gh project field-create`; fall back to GraphQL.
create_iteration() {
  local name="$1"
  if field_exists "$name"; then
    echo "   - [$name] exists, skipping"
    return
  fi
  echo "   - Creating iteration field [$name] (default cadence; set to weekly in UI)"
  gh api graphql -f query='
    mutation($projectId:ID!, $name:String!) {
      createProjectV2Field(input:{
        projectId:$projectId,
        dataType:ITERATION,
        name:$name
      }) {
        projectV2Field {
          ... on ProjectV2IterationField { id name }
        }
      }
    }' \
    -f projectId="$PROJECT_NODE_ID" \
    -f name="$name" >/dev/null
}

echo ">> Adding custom fields..."
create_single_select "Surface" \
  "Studio Site,Arcade Hub,Arcade Game,EchoQuest,One More Night,Last Exit,Blog,Ops,Shared Infra"
create_text "Arcade Game"
create_single_select "Area" \
  "Gameplay,Content,Infra,Tooling,Marketing,SEO,Bug,Chore"
create_single_select "Priority" \
  "P0,P1,P2,P3"
create_iteration "Iteration"

# ---------------------------------------------------------------------------
# Summary + manual follow-ups
# ---------------------------------------------------------------------------
cat <<EOF

----------------------------------------------------------------------
Project ready.

  Number: $PROJECT_NUMBER
  URL:    $PROJECT_URL

Paste the URL into AGENTS.md (search for "TODO: paste Project URL").

Do these in the UI (faster than scripting):

  1. Status field options
     The default Status field comes with Todo / In Progress / Done.
     Edit it to: Backlog, Up Next, In Progress, In Review, Blocked, Done.
     (Single-select options can't be edited via API.)

  2. Iteration field
     The script creates it with a default 2-week cadence. Set it to
     weekly in the field settings if you want weekly iterations.

  3. Saved views (see AGENTS.md "Recommended views" for filter recipes):
     - Now            board, Status = In Progress
     - Up Next        board, Status = Up Next, sort by Priority
     - By surface     board grouped by Surface
     - Arcade games   table, Surface = Arcade Game, grouped by Arcade Game
     - Bugs           table, Area = Bug, sort by Priority
     - Shared infra   table, Surface = Shared Infra
     - Blocked        table, Status = Blocked

  4. Org-level Issue Types (Epic / Feature / Bug / Task)
     Org Settings -> Issues -> Issue types.
----------------------------------------------------------------------
EOF

# ---------------------------------------------------------------------------
# Linking repos (run manually as each game/site repo is created)
# ---------------------------------------------------------------------------
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/<repo>
#
# Examples (uncomment + run as repos come online):
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/echoforge-arcade
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/adventure-quest
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/one-more-night
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/last-exit
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/echoforge-site
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/blog
# gh project link $PROJECT_NUMBER --owner $OWNER --repo echoforge-games/.github

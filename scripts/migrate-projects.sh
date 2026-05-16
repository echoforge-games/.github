#!/usr/bin/env bash
# Migrate legacy per-game GitHub Projects into the new org-level
# "EchoForge - All Work" project. Then close the legacy projects.
#
# Idempotent:
#   - `gh project item-add` returns the existing item if the issue is
#     already in the project (no duplicates).
#   - Setting a field value is repeatable.
#   - `project close` on an already-closed project is a no-op.
#
# Scope (decided up front, hardcoded):
#   Migrate (bruno-civongroup personal projects -> echoforge-games #1):
#     #1 EchoQuest Development  -> Surface=EchoQuest
#     #3 One More Night         -> Surface=One More Night
#     #4 CATastrophe            -> Surface=Arcade Game, Arcade Game="CATastrophe"
#     #6 Last Exit              -> Surface=Last Exit
#     #7 LockBreaker            -> Surface=Arcade Game, Arcade Game="LockBreaker"
#
#   Close after migration:
#     #1, #3, #4, #6, #7
#
#   Close (empty EF projects):
#     #2 One More Night (dup), #5 TileForge Studio, #9 EchoForge Website,
#     #10 EchoQuest Website, #15 Fig Discord Bot
#
#   Left alone (NOT touched by this script):
#     #8 Drakkar Mapper        (user requested keep separate)
#     #11 Lead To Deliver      (non-EF)
#     #12 ThatCivonGuy         (non-EF)
#     #13 BrunoMalnovic        (non-EF)
#     #14 WolfGuild            (non-EF)
#
# Status mapping: legacy projects all use Todo / In Progress / Done.
# The new project still has those defaults; this script preserves them.
# After you rename Todo -> Backlog and add Up Next / In Review / Blocked
# in the UI, existing assignments carry over automatically.

set -euo pipefail

NEW_OWNER="echoforge-games"
NEW_PROJECT_NUMBER="1"
LEGACY_OWNER="bruno-civongroup"

# ---------------------------------------------------------------------------
# Pre-flight: gather project + field IDs from the destination project.
# ---------------------------------------------------------------------------
echo ">> Resolving destination project metadata..."
NEW_PROJECT_ID="$(gh project view "$NEW_PROJECT_NUMBER" --owner "$NEW_OWNER" --format json --jq '.id')"

get_field_id() {
  gh project field-list "$NEW_PROJECT_NUMBER" --owner "$NEW_OWNER" \
    --format json --jq ".fields[] | select(.name == \"$1\") | .id"
}

get_option_id() {
  local field_name="$1"
  local option_name="$2"
  gh project field-list "$NEW_PROJECT_NUMBER" --owner "$NEW_OWNER" \
    --format json \
    --jq ".fields[] | select(.name == \"$field_name\") | .options[] | select(.name == \"$option_name\") | .id"
}

SURFACE_FIELD_ID="$(get_field_id "Surface")"
ARCADE_GAME_FIELD_ID="$(get_field_id "Arcade Game")"
STATUS_FIELD_ID="$(get_field_id "Status")"

OPT_SURFACE_ECHOQUEST="$(get_option_id "Surface" "EchoQuest")"
OPT_SURFACE_OMN="$(get_option_id "Surface" "One More Night")"
OPT_SURFACE_LASTEXIT="$(get_option_id "Surface" "Last Exit")"
OPT_SURFACE_ARCADE="$(get_option_id "Surface" "Arcade Game")"

OPT_STATUS_TODO="$(get_option_id "Status" "Todo")"
OPT_STATUS_INPROGRESS="$(get_option_id "Status" "In Progress")"
OPT_STATUS_DONE="$(get_option_id "Status" "Done")"

echo "   Surface field:     $SURFACE_FIELD_ID"
echo "   Arcade Game field: $ARCADE_GAME_FIELD_ID"
echo "   Status field:      $STATUS_FIELD_ID"

# ---------------------------------------------------------------------------
# Helper: migrate one issue into the new project + set fields.
# ---------------------------------------------------------------------------
status_option_id() {
  case "$1" in
    "Todo")        echo "$OPT_STATUS_TODO" ;;
    "In Progress") echo "$OPT_STATUS_INPROGRESS" ;;
    "Done")        echo "$OPT_STATUS_DONE" ;;
    *)             echo "" ;;
  esac
}

migrate_issue() {
  local issue_url="$1"
  local surface_option_id="$2"
  local arcade_game_text="$3"   # empty unless Surface=Arcade Game
  local legacy_status="$4"      # empty if none

  # Add to new project (idempotent). Capture the resulting item id.
  local new_item_id
  new_item_id="$(
    gh project item-add "$NEW_PROJECT_NUMBER" --owner "$NEW_OWNER" \
      --url "$issue_url" --format json --jq '.id'
  )"

  # Set Surface
  gh project item-edit \
    --project-id "$NEW_PROJECT_ID" \
    --id "$new_item_id" \
    --field-id "$SURFACE_FIELD_ID" \
    --single-select-option-id "$surface_option_id" >/dev/null

  # Set Arcade Game text if applicable
  if [[ -n "$arcade_game_text" ]]; then
    gh project item-edit \
      --project-id "$NEW_PROJECT_ID" \
      --id "$new_item_id" \
      --field-id "$ARCADE_GAME_FIELD_ID" \
      --text "$arcade_game_text" >/dev/null
  fi

  # Preserve Status (Todo / In Progress / Done all exist on the new project)
  if [[ -n "$legacy_status" ]]; then
    local sopt
    sopt="$(status_option_id "$legacy_status")"
    if [[ -n "$sopt" ]]; then
      gh project item-edit \
        --project-id "$NEW_PROJECT_ID" \
        --id "$new_item_id" \
        --field-id "$STATUS_FIELD_ID" \
        --single-select-option-id "$sopt" >/dev/null
    fi
  fi
}

migrate_project() {
  local legacy_num="$1"
  local legacy_title="$2"
  local surface_opt="$3"
  local arcade_game_text="$4"

  echo ""
  echo ">> Migrating legacy project #$legacy_num ($legacy_title) ..."

  # Pull items as TSV: url <TAB> status
  local items_tsv
  items_tsv="$(
    gh project item-list "$legacy_num" --owner "$LEGACY_OWNER" --limit 500 \
      --format json \
      --jq '.items[] | [.content.url, (.status // "")] | @tsv'
  )"

  if [[ -z "$items_tsv" ]]; then
    echo "   (no items, skipping)"
    return
  fi

  local count=0
  while IFS=$'\t' read -r url status; do
    [[ -z "$url" ]] && continue
    count=$((count + 1))
    printf "   [%d] %s  (status: %s)\n" "$count" "$url" "${status:-none}"
    migrate_issue "$url" "$surface_opt" "$arcade_game_text" "$status"
  done <<<"$items_tsv"

  echo "   migrated $count items from #$legacy_num"
}

# ---------------------------------------------------------------------------
# 1. Migrate populated legacy projects
# ---------------------------------------------------------------------------
migrate_project 1 "EchoQuest Development" "$OPT_SURFACE_ECHOQUEST" ""
migrate_project 3 "One More Night"        "$OPT_SURFACE_OMN"       ""
migrate_project 4 "CATastrophe"           "$OPT_SURFACE_ARCADE"    "CATastrophe"
migrate_project 6 "Last Exit"             "$OPT_SURFACE_LASTEXIT"  ""
migrate_project 7 "LockBreaker"           "$OPT_SURFACE_ARCADE"    "LockBreaker"

# ---------------------------------------------------------------------------
# 2. Close legacy projects (idempotent: close on closed = no-op)
# ---------------------------------------------------------------------------
echo ""
echo ">> Closing migrated + empty EF projects..."

# Migrated populated projects:
TO_CLOSE_POPULATED=(1 3 4 6 7)
# Empty EF projects (per user: NOT #8 Drakkar Mapper):
TO_CLOSE_EMPTY=(2 5 9 10 15)

close_project() {
  local n="$1"
  local label="$2"
  local closed
  closed="$(
    gh project view "$n" --owner "$LEGACY_OWNER" --format json --jq '.closed'
  )"
  if [[ "$closed" == "true" ]]; then
    echo "   #$n ($label) already closed, skipping"
    return
  fi
  gh project close "$n" --owner "$LEGACY_OWNER" >/dev/null
  echo "   closed #$n ($label)"
}

for n in "${TO_CLOSE_POPULATED[@]}"; do
  close_project "$n" "migrated"
done
for n in "${TO_CLOSE_EMPTY[@]}"; do
  close_project "$n" "empty"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
cat <<EOF

----------------------------------------------------------------------
Migration complete.

  Destination: https://github.com/orgs/$NEW_OWNER/projects/$NEW_PROJECT_NUMBER

  Migrated and closed (populated):     #1 #3 #4 #6 #7
  Closed (empty EF):                    #2 #5 #9 #10 #15
  Left untouched (kept separate):       #8 Drakkar Mapper
  Left untouched (non-EF):              #11 #12 #13 #14

Next:
  - In the UI, rename Status option "Todo" -> "Backlog" and add
    "Up Next", "In Review", "Blocked". Existing assignments carry over.
  - Triage Area and Priority on migrated issues using a table view
    grouped/filtered by Surface.
----------------------------------------------------------------------
EOF

# EchoForge Games — Org Index

Authoritative map of what we ship, how it's organized, and how to work in this
org. Read this first in any EchoForge repo before searching or assuming.

This file lives in `echoforge-games/.github` and is referenced from each
individual repo's `AGENTS.md`. Keep it tight — it's an index, not docs.

## Studio context

- Solo-dev studio. Heavy Claude usage.
- Default: act on the task, don't pause to confirm. Ask only when the
  request is genuinely ambiguous or a change is hard to reverse.
- Don't reinvent: check this file and the repo's own `AGENTS.md` before
  introducing new tools, services, or patterns.

## What we ship

| Surface | URL | What it is | Repo |
|---|---|---|---|
| Studio site | https://echoforge.games | Marketing + game portal | <!-- TODO: repo name --> |
| Arcade | https://arcade.echoforge.games | Hub for 40+ browser games | <!-- TODO --> |
| EchoQuest | https://play.echoquest.net | Web RPG, procedural dungeons, multiplayer | <!-- TODO --> |
| One More Night | (Steam) | Zombie survival/stealth | <!-- TODO --> |
| Last Exit | https://echoforge.games | Choice-driven survival horror, Godot 4 | <!-- TODO --> |
| Blog | https://blog.echoforge.games | Studio blog | <!-- TODO --> |
| Ops / leadership | https://leadtodeliver.com | Adjacent leadership content site | <!-- TODO --> |
| Org defaults | — | This repo. Org profile + issue templates + this index. | `echoforge-games/.github` |

<!-- TODO: fill in repo names above as repos are linked into the Project. -->

## Tech stack

<!-- TODO: fill in per surface. Suggested fields per row: framework, host, CI, asset pipeline. -->

| Surface | Framework | Host | CI | Notes |
|---|---|---|---|---|
| Studio site | TODO | TODO | TODO | |
| Arcade hub | TODO | TODO | TODO | |
| Arcade games | TODO | TODO | TODO | 40+ titles, see arcade repo's `AGENTS.md` for per-game layout |
| EchoQuest | TODO | TODO | TODO | |
| One More Night | TODO | TODO | TODO | Steam build pipeline |
| Last Exit | Godot 4 | TODO | TODO | |
| Blog | TODO | TODO | TODO | |

## Issue tracking

All work — across every repo above — tracks in **one** org-level GitHub
Project: **"EchoForge — All Work"** (<!-- TODO: paste Project URL -->).

Every issue must be added to the Project. The org-wide issue templates in
this repo (`.github/ISSUE_TEMPLATE/`) prompt for the fields below so they
stay populated automatically.

### Project fields

| Field | Type | Values |
|---|---|---|
| `Surface` | Single select | Studio Site / Arcade Hub / Arcade Game / EchoQuest / One More Night / Last Exit / Blog / Ops / Shared Infra |
| `Arcade Game` | Single select | Only set when `Surface = Arcade Game`. The specific title. Single-select (not text) so views can group/filter by it cheaply. Add an option per arcade title as it ships. |
| `Area` | Single select | Gameplay / Content / Infra / Tooling / Marketing / SEO / Bug / Chore |
| `Priority` | Single select | P0 / P1 / P2 / P3 |
| `Status` | Single select (default) | Backlog / Up Next / In Progress / In Review / Blocked / Done |
| `Iteration` | Iteration | Optional. Weekly. |

### Recommended views

- **Now** — board, `Status = In Progress`
- **Up Next** — board, `Status = Up Next`, sort by `Priority`
- **By surface** — board grouped by `Surface`
- **Arcade games** — table, `Surface = Arcade Game`, grouped by `Arcade Game`
- **Bugs** — table, `Area = Bug`, sort by `Priority`
- **Shared infra** — table, `Surface = Shared Infra`
- **Blocked** — table, `Status = Blocked`

### Issue types (org-level, configured in GitHub)

- **Epic** — multi-week, holds sub-issues
- **Feature** — new functionality
- **Bug** — broken behavior
- **Task** — chore, infra, content

Use **sub-issues** for breakdown (especially for arcade games rolled up
under an "Arcade — <Game>" epic). Don't create a separate Project per
game.

### Project performance & UX

GitHub Projects has no user-tunable indices, but a few choices make the
board feel snappy vs. sluggish. The schema and views above already follow
these rules — keep them in mind when adding more.

- **Auto-archive `Done` items.** Set a built-in workflow to archive items
  where `Status = Done` for 30 days. Archived items still exist, but
  don't load on every view. Without this, the working set creeps and
  every view gets slower.
- **Keep active items under ~1000.** Past that, boards visibly lag.
  Auto-archive plus closing stale `Backlog` items keeps this honest.
- **Prefer table views for high-cardinality groupings.** Grouping a
  *board* by `Arcade Game` (40+ columns) is the slowest possible view.
  The "Arcade games" view is a table for this reason.
- **Single-select beats text for grouping/filtering.** That's why
  `Arcade Game` is a single-select even though it grows over time —
  filters are O(1) on indexed enums vs. text scan.
- **Cap views at ~7–10.** Each view is its own query. Don't make a
  per-game view; filter the existing ones.
- **Scope cross-repo queries.** When a view is for one game, add a
  repository filter (`repo:echoforge-games/<repo>`) so the Project
  doesn't fan out to every linked repo.
- **Avoid deep filter expressions.** Single-field filters are fast;
  multi-clause `AND/OR` with text matches are slow.
- **Labels are a fast fallback.** Project filters require loading the
  Project; label filters work in raw GitHub issue search and are
  cheap. Mirror critical Project fields as labels (e.g. `surface:arcade`,
  `area:bug`) so Claude can search across the org without opening the
  Project.
- **Don't over-iterate.** Keep at most 4–6 active `Iteration` cycles
  visible; archive older ones.

## Conventions for Claude (and any other agent)

- **Branches**: `claude/<short-slug>-<id>` (the harness already does this).
- **Commits**: imperative mood, no emoji, no marketing language.
- **Scope discipline**: do the task; don't refactor adjacent code, add
  fallbacks for impossible cases, or invent features.
- **Before introducing a tool/service**: search this file and the repo's
  `AGENTS.md` first. If you'd add a new dependency, confirm.
- **UI changes**: verify in a browser before claiming done. Say "couldn't
  verify in browser" explicitly if you couldn't.
- **PRs**: don't open one unless the user asks.

## What each game/site repo should have

Every repo in this org should ship a top-level `AGENTS.md` containing:

1. One paragraph: what this repo is and where it deploys.
2. Tech stack and entry points (build, test, run-local commands).
3. Link back to this org index:
   `See org-wide conventions: https://github.com/echoforge-games/.github/blob/main/AGENTS.md`
4. Repo-specific quirks (asset pipeline, save format, content schema, etc.).
5. Where issues for this repo show up in the Project (`Surface = ...`).

Keep it under ~100 lines. If it grows, split into focused docs and link
from `AGENTS.md`.

## When stuck

1. This file.
2. The repo's own `AGENTS.md`.
3. The Project — filter by `Surface` for related open work; an existing
   issue may already capture the problem.
4. Then ask the user.

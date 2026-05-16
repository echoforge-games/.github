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
| Studio site | https://echoforge.games | Marketing + game portal | `echoforge-games/echoforge-studios` |
| Arcade | https://arcade.echoforge.games | Hub for 40+ browser games | `echoforge-games/echoforge-arcade` |
| EchoQuest | https://play.echoquest.net | Web RPG, procedural dungeons, multiplayer | `echoforge-games/adventure-quest` |
| One More Night | (Steam) | Zombie survival/stealth | `echoforge-games/one-more-night` |
| Last Exit | https://echoforge.games | Choice-driven survival horror, Godot 4 | `echoforge-games/last-exit` |
| Blog | https://blog.echoforge.games | Studio blog | `echoforge-games/echoforge-games.github.io` |
| Ops / leadership | https://leadtodeliver.com | Adjacent leadership content site | `bruno-civongroup/lead-to-deliver` |
| Org defaults | — | This repo. Org profile + issue templates + this index. | `echoforge-games/.github` |

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
Project: **"EchoForge — All Work"** (https://github.com/orgs/echoforge-games/projects/1).

Every issue must be added to the Project. The org-wide issue templates in
this repo (`.github/ISSUE_TEMPLATE/`) prompt for the fields below so they
stay populated automatically.

### Project fields

| Field | Type | Values |
|---|---|---|
| `Surface` | Single select | Studio Site / Arcade Hub / Arcade Game / EchoQuest / One More Night / Last Exit / Blog / Ops / Shared Infra |
| `Arcade Game` | Text | Only set when `Surface = Arcade Game`. The specific title. |
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

## Email & notifications

**Don't add a new provider per surface — consolidate.** Check this table before introducing a new SDK or relay.

### Outbound (app-to-user + ops)

| Use case | Provider | Where configured | From address |
|---|---|---|---|
| EQ user emails (verify, password reset, notifications) | SendGrid (API key) | `adventure-quest-accounts-1` + `adventure-quest-server-1` containers on EQ server (`3.208.134.177`); env: `SENDGRID_API_KEY`, `EMAIL_PROVIDER=sendgrid` | `noreply@civongroup.com` |
| OMN game emails | AWS SES | `omn-server` container; env: `AWS_SES_REGION=us-east-1`, `SES_FROM_EMAIL` | `noreply@wolfguild.com` |
| Server ops (unattended-upgrades, cron alerts) | msmtp → SendGrid relay | `/etc/msmtprc` on EQ server (root-only). `msmtp` + `msmtp-mta` + `bsd-mailx` installed | `noreply@civongroup.com` |
| WordPress (Wolfguild) emails | `wp-mail-smtp` plugin | WP server (`54.225.170.153`) | (varies) |

**Active known issue:** SendGrid account is over quota — see `echoforge-games/echoforge-accounts#88`. EQ verification + password-reset emails are silently failing until resolved. Recommended fix: migrate civongroup-sending to AWS SES (would consolidate with OMN; verify `civongroup.com` and `echoquest.net` domains in SES first).

**Adding email to a new surface:** default to **AWS SES** (the direction we're moving toward). Don't add Mailgun/Postmark/Resend without a stated reason. Verify any new sending domain in SES before sending.

### Inbound (read mailbox programmatically)

- **Quick lookups during a Claude session**: Built-in Gmail MCP (`mcp__claude_ai_Gmail__*`) — search/read/draft, no setup.
- **Full R/W from scripts**: `googleapis` Node SDK. OAuth creds at `C:/Users/bruno/.gmail-mcp/`. Scopes: `gmail.modify` + `gmail.settings.basic`.
- **Automated triage**: `D:/projects/alert-agent/` — background service polls Gmail, classifies alerts via Haiku 4.5, files GitHub issues, moves processed alerts to "Alerts - Resolved" label.

### Primary ops recipient

`bruno@civongroup.com` (also receives ahrefs, uptimerobot, statuspage notifications).

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

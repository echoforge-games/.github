> Auto-injected by the [inject-agent-brief workflow](https://github.com/echoforge-games/.github/blob/main/.github/workflows/inject-agent-brief.yml). Edit in `.github/agent-briefs/task.md` in `echoforge-games/.github`.

<agent-brief>
  <type>task</type>
  <context>
    Before acting, ground yourself:
    1. Note the Surface, Area, Priority, and (if applicable) Arcade Game values from the form fields above. Don't assume — read them.
    2. Look up the Surface in the org index for tech stack & host: https://github.com/echoforge-games/.github/blob/main/AGENTS.md#tech-stack
    3. Read this repo's own AGENTS.md for repo-specific quirks (entry points, build commands, conventions).
    4. Skim the Project filtered by this Surface for related open work / duplicates (Project URL in the org index "Issue tracking" section).
  </context>
  <triage>
    1. Confirm Surface, Area, Priority.
    2. Is this a duplicate or stale? If so, link/close and stop.
  </triage>
  <process>
    1. Do the work.
    2. If it changes a convention (build tool, lint rule, naming), update AGENTS.md in the same PR.
  </process>
  <constraints>
    - Keep changes scoped to the stated task.
    - Open a PR if changes are non-trivial or touch shared infra. Direct commits acceptable for trivial chores.
  </constraints>
  <deliverables>
    - Completed task
    - AGENTS.md update if conventions changed
  </deliverables>
  <read>https://github.com/echoforge-games/.github/blob/main/AGENTS.md</read>
</agent-brief>

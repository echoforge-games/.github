> Auto-injected by the [inject-agent-brief workflow](https://github.com/echoforge-games/.github/blob/main/.github/workflows/inject-agent-brief.yml). Edit in `.github/agent-briefs/task.md` in `echoforge-games/.github`.

<agent-brief>
  <type>task</type>
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

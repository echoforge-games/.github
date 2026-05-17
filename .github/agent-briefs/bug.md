> Auto-injected by the [inject-agent-brief workflow](https://github.com/echoforge-games/.github/blob/main/.github/workflows/inject-agent-brief.yml). Edit in `.github/agent-briefs/bug.md` in `echoforge-games/.github`.

<agent-brief>
  <type>bug</type>
  <context>
    Before acting, ground yourself:
    1. Note the Surface, Area, Priority, and (if applicable) Arcade Game values from the form fields above. Don't assume — read them.
    2. Look up the Surface in the org index for tech stack & host: https://github.com/echoforge-games/.github/blob/main/AGENTS.md#tech-stack
    3. Read this repo's own AGENTS.md for repo-specific quirks (entry points, build commands, conventions).
    4. Skim the Project filtered by this Surface for related open work / duplicates (Project URL in the org index "Issue tracking" section).
  </context>
  <triage>
    1. Confirm Surface, Area, and Priority are set in the Project. If not, propose values and ask.
    2. Search the Project for duplicates by title/keywords. If a match exists, link it and stop.
    3. If "What happened" or "Steps to reproduce" is empty or vague, ask one targeted question before coding.
  </triage>
  <process>
    1. Reproduce the bug (locally or by reading code) before fixing.
    2. Find root cause. Do not patch symptoms with try/catch, null guards, or workarounds.
    3. Write a regression test that fails before the fix and passes after.
    4. Apply the smallest fix that addresses the root cause.
    5. Update CHANGELOG if the bug was user-visible.
  </process>
  <constraints>
    - No adjacent refactors ("while I'm in here" cleanup).
    - No new dependencies without confirming.
    - Open a PR — never push directly to main.
  </constraints>
  <deliverables>
    - Failing-then-passing regression test
    - Minimal root-cause fix
    - CHANGELOG entry if user-facing
    - PR linked to this issue
  </deliverables>
  <read>https://github.com/echoforge-games/.github/blob/main/AGENTS.md</read>
</agent-brief>

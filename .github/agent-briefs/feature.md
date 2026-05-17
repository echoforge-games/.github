> Auto-injected by the [inject-agent-brief workflow](https://github.com/echoforge-games/.github/blob/main/.github/workflows/inject-agent-brief.yml). Edit in `.github/agent-briefs/feature.md` in `echoforge-games/.github`.

<agent-brief>
  <type>feature</type>
  <context>
    Before acting, ground yourself:
    1. Note the Surface, Area, Priority, and (if applicable) Arcade Game values from the form fields above. Don't assume — read them.
    2. Look up the Surface in the org index for tech stack & host: https://github.com/echoforge-games/.github/blob/main/AGENTS.md#tech-stack
    3. Read this repo's own AGENTS.md for repo-specific quirks (entry points, build commands, conventions).
    4. Skim the Project filtered by this Surface for related open work / duplicates (Project URL in the org index "Issue tracking" section).
  </context>
  <triage>
    1. Confirm Surface, Area, Priority, and "Definition of done" are populated.
    2. Search the Project for duplicates or related epics. Link if found.
    3. If DoD is empty or vague, post a proposed DoD as a comment and wait for sign-off before coding.
  </triage>
  <process>
    1. Read DoD. If you would build anything outside it, ask first.
    2. Build the smallest version that satisfies DoD. No speculative options or config.
    3. Add tests for the golden path and 1–2 obvious edge cases.
    4. Update README / docs for user-visible behavior.
    5. Add a CHANGELOG entry.
  </process>
  <constraints>
    - Always open a PR for enhancements. Never push directly to main.
    - Gate risky changes behind a feature flag (live games, payments, save format).
    - No speculative configuration, options, or abstractions.
  </constraints>
  <deliverables>
    - Working feature meeting DoD
    - Golden-path + edge-case tests
    - README / doc updates for user-visible behavior
    - CHANGELOG entry
    - PR linked to this issue
  </deliverables>
  <read>https://github.com/echoforge-games/.github/blob/main/AGENTS.md</read>
</agent-brief>

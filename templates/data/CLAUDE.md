# Household OS runtime instructions

Use the project-scoped Household OS skill that matches the request's primary intent. Do not load all skills or all household data by default.

## Route by intent

- Use `financial-advisor` for money, taxes, cash flow, retirement, financial independence, investments, insurance, real estate, education funding, and major purchases.
- Use `parenting` for child development, behavior, discipline, emotions, learning, autonomy, peer relationships, co-parenting, and family dynamics.
- Use `wellness-coach` for adult exercise, nutrition, mobility, recovery, sleep, stress, health habits, supplements, and workout creation.

Use more than one skill only when the request is materially cross-domain. For mixed questions, choose the skill matching the primary decision and add another only for a distinct part of the answer. Child health remains a parenting-context question that may require a pediatric professional; do not silently apply adult wellness guidance. The phrase "financial wellness" alone does not invoke the wellness coach.

## Read private data selectively

Read only the relevant files under `shared/` and `modules/<skill-name>/`. Do not assume a fact that is absent, and do not load unrelated modules merely because they are available. Treat dates, balances, laws, health context, developmental stages, and service configuration as potentially stale.

## Activate modules deliberately

A module is not activated while its baseline files still say that no baseline has been reviewed.

When asked to activate a module:

1. Ask for a source file or onboarding answers if none were provided.
2. Separate personal facts, relationships, goals, preferences, constraints, and current state from general methodology.
3. Preserve public frameworks, books, authors, and methodologies in the skill; do not write instruction prose into private profile files.
4. Consolidate duplicate or conflicting personal facts and flag uncertainty or staleness.
5. Show the proposed private baseline and destination files for review.
6. Write only after explicit approval.

When asked to activate all modules, perform the same review one module at a time. Never copy a source prompt wholesale into this repository.

## Persist only durable information

Default to not saving. Save only when at least one of these applies:

- a reviewed activation baseline
- a material change to a known profile
- a finalized decision or plan
- a recurring trend supported by separate events or conversations
- an explicit request to save or remember
- a workout or workout result saved to the configured Notion database

Summarize durable trends and decisions; do not save raw transcripts. Do not save one-off anecdotes, passing emotions, routine meals or workouts, speculative financial scenarios, unchosen options, or generated advice as if it were a decision. Ask before writing when durability or intent is ambiguous.

Do not store passwords, access tokens, or authentication secrets.

## Keep workouts in Notion only

Notion is the sole workout record. If the Notion tool, connection, or configured database is unavailable, say plainly that the workout was not saved and that the user must configure Notion. A generated workout may remain in the conversation, but do not create a local duplicate, hidden queue, fallback database, or schema change.

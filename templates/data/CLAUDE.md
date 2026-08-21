# Household OS runtime instructions

Use the project-scoped Household OS skill that matches the request's primary intent. Do not load all skills or all household data by default.

## Route by intent

- Use `financial-advisor` for money, taxes, cash flow, retirement, financial independence, investments, insurance needs, real-estate economics, education funding, and major purchases.
- Use `general-contractor` for physical home or site condition, maintenance, diagnosis, repair, building systems, materials, remodels, additions, rehabs, roofing, scope, codes and permits, bids, contractors, workmanship, and rough construction cost. Building-hazard identification and property remediation remain here.
- Use `legal-advisor` for legal rights and duties, wills, trusts, powers of attorney, advance directives, probate, family law, leases, landlord-tenant and property law, contracts, consumer and employment rights, disputes, court or agency procedure, and legal documents.
- Use `parenting` for child development, behavior, discipline, emotions, learning, autonomy, peer relationships, co-parenting, and family dynamics.
- Use `wellness-coach` for adult exercise, nutrition, mobility, recovery, sleep, stress, health habits, supplements, and workout creation.

Use more than one skill only when the request has material, distinct components. For mixed questions, choose the skill matching the primary decision and add another only for a distinct part of the answer. Use `general-contractor` for physical scope, methods, codes, bids, workmanship, and hazards; use `financial-advisor` for affordability, financing, tax treatment, or investment return; and use `legal-advisor` for contract rights, enforceability, liability, liens, disputes, insurance-coverage interpretation, or procedure. Use `wellness-coach` for adult personal health decisions. Route child symptoms or health context to `parenting`, together with appropriate pediatric care; do not silently apply adult wellness guidance. The phrase "financial wellness" alone does not invoke the wellness coach.

## Read private data selectively

Read only the relevant files under `shared/` and `modules/<skill-name>/`. Do not assume a fact that is absent, and do not load unrelated modules merely because they are available. Treat dates, balances, laws, codes, product instructions, property conditions, health context, developmental stages, and service configuration as potentially stale.

## Use universal notes deliberately

Store free-form research, plans, projects, matters, decisions, trends, tasks, sources, and outcomes as Markdown notes. Put each note under its owning module whenever it has a clear primary domain:

- `modules/financial-advisor/notes/`
- `modules/general-contractor/notes/`
- `modules/legal-advisor/notes/`
- `modules/parenting/notes/`
- `modules/wellness-coach/notes/`

Use top-level `notes/` only for genuinely cross-functional content with no clear primary module. Keep one canonical note only; when ownership changes, move it rather than copying it.

These are conversational operations, not a command-line interface: create, add to, show, list, search, rename, and move notes, including ordinary natural-language equivalents. When the destination is clear, an explicit request to create, add, rename, or move authorizes that operation. Write user-provided content directly. Before saving assistant-generated or materially summarized content, show the proposed note for review. For an ambiguous note name, show matching paths rather than guessing.

Create a `notes/` directory only when creating or moving the first note into it. Treat a missing notes directory as empty for list and search. Do not load notes automatically: read a named note, list paths or lightweight metadata, or search note bodies only when explicitly requested. Constrain that action to the routed module unless the user asks more broadly. Notes remain until the user manually deletes the Markdown file. Do not create archives, lifecycle or status schemes, managed delete commands, placeholder files, automatic migrations, legacy fallbacks, or compatibility storage.

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

For `general-contractor`, keep durable facts in one approved primary-property baseline and related universal notes. After review, save finalized scope, decisions, dates, and durable outcomes only when user approval or clear intent supports it. Do not save raw conversations, transient diagnoses or guesses, access or security codes, full bids, full inspection reports, or generated advice as an approved plan.

For legal matters, do not assume household members have aligned interests. Default to not saving sensitive legal content, and do not treat ordinary conversation, a question, or the user's sharing of material as authorization to save it. An explicit request to save does authorize saving user-provided legal research, narratives, allegations, admissions, strategy, criminal or immigration narratives, abuse details, opposing parties' private information, attorney communications, evidence, discovery, legal documents, and other sensitive material. Before writing it, give a concise warning that repository access or sync and Git history (including prior versions after editing or deletion) can retain or expose it; do not require a second confirmation unless the user withdraws or changes the request. For assistant-generated or materially summarized legal research, analysis, or strategy, show the proposed content for review and obtain explicit approval before saving. For exceptionally sensitive material, recommend encrypted, non-Git storage. That recommendation does not override an explicit user choice to save it here.

## Keep workouts in Notion only

Notion is the sole workout record. If the Notion tool, connection, or configured database is unavailable, say plainly that the workout was not saved and that the user must configure Notion. A generated workout may remain in the conversation, but do not create a local duplicate, hidden queue, fallback database, or schema change.

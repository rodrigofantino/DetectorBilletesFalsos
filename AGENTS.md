# agents.md — Flip Deck Dungeon (Codex)


# ~/.codex/AGENTS.md

## Working agreements
- When a task is large, ambiguous, or parallelizable, explicitly use subagents.
- Prefer spawning specialized subagents for exploration, review, or isolated implementation work.

## Purpose
Act as a senior game-engineer assistant for this repository. Prioritize correctness, maintainability, and minimal diffs.
We are building **Detector de Billetes Falsos**, an Android App made in 2015 on ECLIPSE that needs to be ported to **Godot 4.5**.

## Session bootstrap (MANDATORY)
Run this bootstrap only once at the beginning of each new Codex session.

Bootstrap steps:
1. Open and read the project design docs:
   - `IDD.txt`
   - `GDD.txt`
   - `TDD.txt`
2. Treat these files as the source of truth for gameplay rules, terminology, and system constraints.
3. If any of the files are missing or renamed, search the repo for the closest equivalents and read them.
4. Store the resulting constraints in working memory for the rest of the session.
5. Do not re-read these files on every user request during the same session unless:
   - the user explicitly asks to re-check them,
   - the files were modified during the session,
   - or a conflict/uncertainty requires verification.

## Core rules
- **Do not invent files, APIs, or systems.** If something is unclear, inspect the repo first or propose a safe implementation.
- Prefer **small, reviewable changes**. Avoid large refactors unless explicitly asked.
- Preserve existing **architecture and naming**. Follow the project’s conventions.
- Avoid breaking gameplay rules documented in IDD/GDD/TDD. If a request conflicts, flag it.
- Never commit secrets or tokens.

## Local-only files
- Keep `keys posibles/` for recovered or candidate signing keys. The folder is local-only and must stay ignored by git.
- Treat `run_codex_full_permisions.bat` as a local helper script. Do not commit it unless the user explicitly asks.

## Context budget warning (MANDATORY)
If you estimate you have **20% or less** of the available context window remaining:
- Emit a clear warning: **"WARNING: Low context budget (≤20%)."**
- Then switch to a more compact mode:
  - summarize current state (5–10 bullets),
  - prioritize essential work only,
  - avoid long code dumps; prefer file/diff references and minimal patches.

## Editing method (MANDATORY)
- Prefer the **standard file edit / patch tool** provided by Codex (apply_patch / edit_file / file editor) whenever available.
- Avoid editing files via shell commands (e.g., `sed`, `echo >`, heredocs) unless there is no other option.
- Avoid destructive file operations; if removal is required, follow the deletion rule (ask first).

## Autonomy (FULL ACCESS DEFAULT)
You have full autonomy to implement changes without asking for confirmation, **by default**.

### Default behavior
- Make the best reasonable assumptions and proceed.
- Prefer the smallest change that satisfies the request.
- If multiple implementations are viable, pick one and proceed (no polling), and briefly note the alternative.

### Only ask a question if blocking
Ask only when the request is impossible to execute without a missing fact (e.g., a filename, a node path, a required value), AND you cannot safely infer it from the repo.

### Preference resolution
If asked to choose naming, foldering, or minor UX behavior, choose the option most consistent with existing repo conventions. Do not ask.

## Git autonomy (LOCAL) — NO CONFIRMATIONS
For LOCAL git operations (no remote interaction), proceed without asking questions or requesting confirmation in chat.

**Allowed without confirmation (LOCAL ONLY):**
- `git status`, `git diff`, `git log`
- `git add` (including `git add -A` when appropriate)
- `git commit -m "..."` (create commits autonomously)
- `git restore` / `git checkout -- <file>` (only to revert uncommitted changes)
- `git reset --soft` (only if needed to amend a commit locally)
- `git stash` / `git stash pop` (local safety)

**Rules for local commits:**
1) Stage only files relevant to the task (avoid unrelated noise).
2) Never commit generated/export artifacts (respect `.gitignore`).
3) Choose a clear commit message using this format:
   - `feat: ...`, `fix: ...`, `chore: ...`, `docs: ...`
4) After committing, report:
   - commit message used
   - files included (short list)
   - `git status` summary (clean/dirty)

### Hard stops (must ask before proceeding)
Codex MUST ask before:

**A) Git remote operations**
- If the user explicitly requests a remote action (e.g., "git push", "push to origin development"), perform it without additional confirmation.
- If the user did NOT explicitly request it, ask before doing any remote operation.

If a remote operation fails (timeout/auth), retry up to 2 times automatically using safe adjustments (e.g., increased timeout / verbose), then stop and report full error output and suggested next steps.


**B) Destructive operations**
- Deleting or removing any files (including `.tscn`, `.tres`, `.gd`, assets, data, localization), or large directory cleanups.
- Any change that effectively deletes content:
  - moving files in a way that breaks references without updating them
  - replacing a file with an empty/stub version
  - removing scenes/resources from the project
- Changing save/data formats in a breaking way or irreversible migrations
- Anything that risks corrupting user data

Everything else is allowed without asking.


## Godot workflow expectations
- Prefer edits that work with Godot’s scene/resource system:
  - `.tscn`, `.tres`, `.gd`, `.gdshader`, `.import`
- Keep node paths stable; avoid renaming nodes unless necessary.
- Avoid unnecessary reserialization noise in `.tscn/.tres` (touch only what you change).

## Godot executable path
- Godot 4.5.1 (Windows): `C:\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe`

## Godot coding guidelines
- Use typed GDScript where it already exists.
- Avoid heavy per-frame logic; prefer signals, timers, and events.
- Log errors with clear context; fail safely.
- If adding new systems, integrate minimally and keep changes localized.

## Art / assets rules (important)
- Do not resize or recompress source art unless asked.
- Preserve transparency/alpha masks exactly when working with UI frames.
- Avoid placeholders unless requested.

## Local secrets / helper files
- Treat `keys posibles/` as local-only signing material. Keep it ignored in `.gitignore` and do not commit its contents.
- Treat `run_codex_full_permisions.bat` as machine-local unless it is rewritten to remove absolute paths and secret references.
- Never place keystores, keys, or backup signing files under version control.

## Game design constraints (known)
- Status effects:
  - Poison: damage is **% of damage** with **minimum 1**, stacking allowed, and state **clears on level up**.
  - Hero does **not** apply poison by default unless specifically requested.
- Traits:
  - Traits have **3 levels**.
  - Upgrading replaces the previous level.
  - **Level 3 has a special perk**.

## Live task checklist (MANDATORY)
For any request that requires edits or analysis:
- Create a checklist titled **"Task Progress"** at the top of the response.
- Break work into 5–15 concrete items (file-level or feature-level steps).
- As you work, update the checklist by marking completed items with `[x]`.
- The final response must include the checklist with all completed items marked, and any remaining items clearly labeled as blocked or out of scope.

### Checklist format (use this)
- [ ] Step 1 ...
- [x] Step 2 ...

## Communication style
- Start with a short plan (3–7 bullets).
- Show the complete list of things to do and update once a thing in the list is done.
- Then list files to change.
- Provide only relevant snippets/diffs and explain where they go.
- If there are alternatives, give 2 options max and recommend one.

## Output format for implementation tasks
1. Task Progress checklist
2. Plan (bullets)
3. Files to change (list)
4. Patch (snippets / diffs)
5. Quick test checklist (how to verify in Godot)

## On commit
1. set a version number higher than last incrementing by 0.001 ( version format is a number with 3 decimals)
2. add commits in changelog.txt using the folowing format: V.VersionNumber_Changes Where Changes is a short summary of changes, never add filenames. 

## Mandatory triage before implementation (MANDATORY)
Before making any edit, always perform a triage step.

### Triage goals
Classify the task as one of:
- trivial
- medium
- risky

### Triage rules
A task is **trivial** only if all of the following are true:
- the ownership of the behavior is obvious,
- the change is localized,
- it does not affect save/load, runtime state, signals, scene wiring, or active-vs-legacy routing,
- it does not require architectural judgment.

A task is **medium** if it touches multiple files or systems, but the implementation path is still reasonably bounded.

A task is **risky** if it affects:
- save/load,
- runtime state ownership,
- autoload state,
- scene wiring or signals,
- active-vs-legacy routing,
- combat flow, map flow, or player deck persistence,
- or if the ownership is unclear.

### Mandatory behavior after triage
- If the task is **trivial**, implement directly with the smallest safe patch.
- If the task is **medium** or **risky**, do NOT jump straight into implementation.
- For medium/risky tasks, explicitly spawn/delegate subagents and wait for their requested results before producing the final answer.
- Use the following default delegation unless the task clearly needs a different split:
  1. use `godot_explorer` to map ownership, affected files, scenes, nodes, and signals;
  2. use `godot_reviewer` if there is architecture, regression, persistence, or scene-wiring risk;
  3. use `godot_worker` to implement the smallest correct patch;
  4. use `godot_reviewer` for final review.

### Mandatory delegation prompt line
For medium/risky tasks, include an explicit delegation instruction in the working prompt, equivalent to:
- "Spawn/delegate subagents for this task. Use `godot_explorer` for mapping, `godot_worker` for implementation, and `godot_reviewer` for review. Wait for all requested agent results before answering."

### Reporting
For every non-trivial task, explicitly report:
- triage result,
- why the task is not trivial,
- which agent roles are being used,
- what each agent is responsible for,
- and why delegation is necessary.

### Agent visibility
When subagents are used, always expose the work split in the response, for example:
- `godot_explorer`: ownership mapping
- `godot_worker`: implementation
- `godot_reviewer`: regression/final review

If the environment exposes agent threads, mention that the user can inspect/switch them with `/agent`.

### Important limitation
Treat subagent delegation as mandatory for medium/risky tasks, but only when the environment supports invoking those agents in the current workflow.
Codex does not spawn subagents automatically unless explicitly instructed to do so.



## Mandatory agent assignment reporting
Whenever subagents are used, explicitly report the assignment before or during implementation.

Required format:
- `godot_explorer` -> [what it is mapping]
- `godot_worker` -> [what it is implementing]
- `godot_reviewer` -> [what it is reviewing]

If the assignment changes mid-task, report the updated split.

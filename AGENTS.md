# Repository Agent Guide

This repository is meant to be handed to agents after a separate goal statement from the user.

Recommended handoff pattern:

1. First message: the goal.
2. Second message: this repository and its guidance.

When that happens, treat the user goal as authoritative and use this file to localize the work quickly.

## First Read Order

Read in this order unless the task is trivial:

1. `AGENTS.md`
2. One smallest matching helper:
   - `ai/entrypoints.md` for keyword or feature-name routing
   - `ai/debug_routes.md` for symptom-first bug reports
   - `ai/type_index.md` for BYOND type paths
   - `ai/runtime_flow.md` for lifecycle, order, or timing
   - `ai/system_dependencies.md` for cross-system handoffs
3. Up to 2 relevant source files
4. Escalate only if unresolved:
   - `ai/system_map.md`
   - `ai/subsystem_map.md`
   - `ai/architecture.md`
   - `ai/type_tree.md`
   - `ai/task_templates.md`

## Read Budget

Stage 1:

- `AGENTS.md`
- exactly 1 small helper file
- at most 2 source files

Stage 2:

- at most 1 additional helper file
- at most 2 more source files

Stage 3:

- only then open large maps or do broader repository searches
- do not open `ai/system_map.md`, `ai/subsystem_map.md`, or `ai/type_tree.md` by default

If the task is still unclear after Stage 2, explain the ambiguity and then escalate.

## Routing Algorithm

1. Classify the task as one of: keyword, symptom, type path, lifecycle/order, cross-system handoff, or `SS*`.
2. Open the cheapest matching helper file.
3. Open the nearest source files for that route.
4. Check whether `modular_rmh` extends the same branch.
5. Escalate to larger maps only if ambiguity remains.

## Operating Rules

- Do not start with a full repository scan if the maps already narrow the task.
- Resolve the task to a system first: type path, subsystem, module family, or runtime layer.
- Check `modular_rmh` after locating the core implementation in `code/`; RMH is a late overlay layer and often extends existing paths instead of replacing them.
- For scheduler or startup issues, open `code/world.dm`, `code/controllers/master.dm`, and `code/controllers/subsystem.dm` early.
- For UI issues, inspect both the DM side (`code/modules/tgui`, `code/modules/visual_ui`, `interface`) and the TS side (`tgui/packages`).
- For gameplay state issues, expect signals/components/status effects to be involved before assuming a direct proc chain.
- Prefer one narrow search plus one helper file over multiple helper files in a row.

## Expected Task Intake

The best tasks include:

- Goal: what should change or be explained.
- Context: type path, `SS*`, directory, feature name, or reproduction scenario.
- Constraints: what not to touch, acceptable scope, balance or compatibility limits.
- Verification: what behavior should be true after the work.

If context is missing, use `ai/entrypoints.md` first.
If the task is symptom-first, use `ai/debug_routes.md`.
If multiple systems are involved, use `ai/system_dependencies.md`.
If the question is about execution order or lifecycle, use `ai/runtime_flow.md`.
If the task gives a type path, use `ai/type_index.md` before `ai/type_tree.md`.
If the fast route is still ambiguous, use `ai/system_map.md`.
If runtime ownership is unclear, use `ai/subsystem_map.md`.
If deep inheritance is the problem, use `ai/type_tree.md`.

## Quick Routing

- Cheapest keyword-to-system route: `ai/entrypoints.md`
- Cheapest symptom-to-route map: `ai/debug_routes.md`
- Cross-system handoff question: `ai/system_dependencies.md`
- Lifecycle / tick / order question: `ai/runtime_flow.md`
- Unknown BYOND type path: `ai/type_index.md`
- Bug in a gameplay feature: `ai/system_map.md`
- Deep inheritance/type branch: `ai/type_tree.md`
- `SS*` global or processing loop: `ai/subsystem_map.md`
- "Where does this live?" architectural question: `ai/architecture.md`
- Need a stronger prompt or intake format: `ai/task_templates.md`

## Default Work Pattern

1. Classify the request.
2. Open one small helper file.
3. Open only the relevant source files.
4. Check whether `modular_rmh` extends the same path.
5. Escalate only if still ambiguous.
6. Make the smallest justified change.
7. Verify against the requested behavior.

## Notes for Human Operators

If you are giving this repo to another agent, the shortest effective pattern is:

- Message 1: "Here is the goal."
- Message 2: "Here is the repository; start with `AGENTS.md`."

If you want more predictable execution, compose message 1 using one of the templates in `ai/task_templates.md`.

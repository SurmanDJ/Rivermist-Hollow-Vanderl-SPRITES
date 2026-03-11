# Repository Agent Guide

This repository is meant to be handed to agents after a separate goal statement from the user.

Recommended handoff pattern:

1. First message: the goal.
2. Second message: this repository and its guidance.

When that happens, treat the user goal as authoritative and use this file to localize the work quickly.

## First Read Order

Read in this order unless the task is trivial:

1. `AGENTS.md`
2. `ai/entrypoints.md` for the cheapest first-pass route
3. `ai/system_dependencies.md` if the task crosses more than one system
4. `ai/runtime_flow.md` if the task is about order, lifecycle, or runtime ownership
5. `ai/architecture.md`
6. `ai/system_map.md`
7. `ai/subsystem_map.md` if the task mentions `SS*`, scheduling, processing, round flow, or runtime ownership
8. `ai/type_tree.md` if the task mentions a BYOND type path or unknown inheritance branch
9. `ai/task_templates.md` if you need a stronger intake structure or want to convert a vague goal into an execution plan

## Operating Rules

- Do not start with a full repository scan if the maps already narrow the task.
- Resolve the task to a system first: type path, subsystem, module family, or runtime layer.
- Check `modular_rmh` after locating the core implementation in `code/`; RMH is a late overlay layer and often extends existing paths instead of replacing them.
- For scheduler or startup issues, open `code/world.dm`, `code/controllers/master.dm`, and `code/controllers/subsystem.dm` early.
- For UI issues, inspect both the DM side (`code/modules/tgui`, `code/modules/visual_ui`, `interface`) and the TS side (`tgui/packages`).
- For gameplay state issues, expect signals/components/status effects to be involved before assuming a direct proc chain.

## Expected Task Intake

The best tasks include:

- Goal: what should change or be explained.
- Context: type path, `SS*`, directory, feature name, or reproduction scenario.
- Constraints: what not to touch, acceptable scope, balance or compatibility limits.
- Verification: what behavior should be true after the work.

If context is missing, use `ai/entrypoints.md` first.
If multiple systems are involved, use `ai/system_dependencies.md`.
If the question is about execution order or lifecycle, use `ai/runtime_flow.md`.
If the fast route is still ambiguous, use `ai/system_map.md`.
If runtime ownership is unclear, use `ai/subsystem_map.md`.
If the type branch is unclear, use `ai/type_tree.md`.

## Quick Routing

- Cheapest keyword-to-system route: `ai/entrypoints.md`
- Cross-system handoff question: `ai/system_dependencies.md`
- Lifecycle / tick / order question: `ai/runtime_flow.md`
- Bug in a gameplay feature: `ai/system_map.md`
- Unknown inheritance/type branch: `ai/type_tree.md`
- `SS*` global or processing loop: `ai/subsystem_map.md`
- "Where does this live?" architectural question: `ai/architecture.md`
- Need a stronger prompt or intake format: `ai/task_templates.md`

## Default Work Pattern

1. Map the goal to one system.
2. Open only the relevant files for that system.
3. Check whether `modular_rmh` extends the same path.
4. Make the smallest justified change.
5. Verify against the requested behavior.

## Notes for Human Operators

If you are giving this repo to another agent, the shortest effective pattern is:

- Message 1: "Here is the goal."
- Message 2: "Here is the repository; start with `AGENTS.md`."

If you want more predictable execution, compose message 1 using one of the templates in `ai/task_templates.md`.

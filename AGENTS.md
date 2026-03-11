# Repository Agent Guide

This repository is meant to be handed to agents after a separate goal statement from the user.

The `ai/` maps are a navigation aid, not a source of truth. They may lag behind the codebase by up to one monthly manual refresh cycle. Use them to localize work quickly, then verify against source files before making conclusions or edits. If maps and code disagree, trust the code and report the mismatch.

Recommended handoff pattern:

1. First message: the goal.
2. Second message: this repository and its guidance.

## Bootstrap

1. Open `ai/router.md`.
2. Choose exactly 1 helper file.
3. Open up to 2 source files.
4. Check the same branch in `modular_rmh`.
5. Escalate only if unresolved.

Do not start with a full repository scan if the maps already narrow the task.
If a whole process loop or effect family freezes without runtimes, sweep for blocking calls before blaming load.
If the owner is known but the cause is still unclear, use `ai/failure_modes.md` to classify the break mode before guessing.

## If You Need More

- task framing: `ai/task_templates.md`
- process-chain hazards: `ai/processing_hazards.md`
- subsystem/process failure classification: `ai/failure_modes.md`
- larger system map: `ai/system_map.md`
- runtime ownership: `ai/subsystem_map.md`
- architecture/layers: `ai/architecture.md`
- deep inheritance: `ai/type_tree.md`

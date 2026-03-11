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
Before edits, classify the planned change with `ai/human_checking.md`.
Do not edit medium-risk, high-risk, or ambiguous-scope changes until the human approves the intended blast radius.
For new content or mechanics, define who uses it and how often first; then prefer the narrowest existing host and cheapest trigger surface before introducing components, global hooks, or broad type coverage.
If a whole process loop or effect family freezes without runtimes, sweep for blocking calls before blaming load.
If the owner is known but the cause is still unclear, use `ai/failure_modes.md` to classify the break mode before guessing.

## If You Need More

- task framing: `ai/task_templates.md`
- human approval and risk gates: `ai/human_checking.md`
- content-first implementation rules: `ai/content_creation.md`
- content feature decomposition: `ai/content_breakdown.md`
- content implementation archetypes: `ai/content_patterns.md`
- signal routing and DCS hotspots: `ai/signal_map.md`
- core proc families and entry hooks: `ai/core_procs.md`
- process-chain hazards: `ai/processing_hazards.md`
- subsystem/process failure classification: `ai/failure_modes.md`
- larger system map: `ai/system_map.md`
- runtime ownership: `ai/subsystem_map.md`
- architecture/layers: `ai/architecture.md`
- deep inheritance: `ai/type_tree.md`

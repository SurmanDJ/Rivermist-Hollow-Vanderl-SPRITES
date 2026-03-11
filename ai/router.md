# Router

Generated on 2026-03-11. Use this file to choose exactly one small helper before opening source files.

The `ai/` maps may lag behind the codebase by up to one monthly manual refresh cycle. Use them for routing, then verify in source. If maps and code disagree, trust the code.

## Dispatch

| If the task looks like | Open this helper |
|---|---|
| symptom-first bug report | `ai/debug_routes.md` |
| keyword or feature-name routing | `ai/entrypoints.md` |
| BYOND type path like `/datum/...`, `/mob/...`, `/obj/...` | `ai/type_index.md` |
| lifecycle, order, timing, scheduler, round flow | `ai/runtime_flow.md` |
| cross-system handoff or dependency question | `ai/system_dependencies.md` |
| explicit `SS*` subsystem question | `ai/subsystem_map.md` |
| unknown architecture/location question after the above | `ai/system_map.md` or `ai/architecture.md` |
| deep inheritance problem | `ai/type_tree.md` |

## Budget

- Open exactly 1 helper first.
- Then open up to 2 source files.
- Check `modular_rmh` on the same branch.
- Escalate only if unresolved.

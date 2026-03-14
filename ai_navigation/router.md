# Router

Generated on 2026-03-11. Last validated 2026-03-14. This is the primary Fast Start entrypoint for normal tasks.

## Always

| When | Action |
|---|---|
| before any medium / high / unclear-scope edit | open `ai_navigation/human_checking.md` first |

## Dispatch

| Task | Helper |
|---|---|
| planned change may be broad, risky, or needs approval before edits | `ai_navigation/human_checking.md` |
| refresh the navigation layer, rebuild its docs, or migrate this repository-orientation stack to another codebase | `ai_navigation/update_policy.md` |
| new mechanic, gameplay content, or extension to an existing feature — and the implementation shape is already known | `ai_navigation/content_creation.md` |
| content request is vague and needs delivery/base/delta/effect decomposition | `ai_navigation/content_breakdown.md` |
| content goal is known but the implementation form (override? component? element? signal listener?) is undecided | `ai_navigation/content_patterns.md` |
| existing behavior seems indirect, DCS-driven, or routed through signal listeners rather than obvious proc calls — and you are **debugging** not implementing | `ai_navigation/signal_map.md` |
| implementing a new component, element, or signal listener as part of new content — choose this **before** signal_map.md | `ai_navigation/content_patterns.md` → then `ai_navigation/signal_map.md` for the signal contract |
| spell, miracle, or cooldown action behavior depends on both core procs and signals | `ai_navigation/spell_signal_map.md` |
| melee, projectile, hit, disarm, or combat chains depend on both core procs and signals | `ai_navigation/combat_signal_map.md` |
| client movement, collisions, buckle, pull, throw, or moveloop behavior depends on both core procs and signals | `ai_navigation/movement_signal_map.md` |
| you need the main proc entrypoints before searching source | `ai_navigation/core_procs.md` |
| whole subsystem or process loop freezes, hangs, or stops without runtimes | `ai_navigation/processing_hazards.md` |
| explicit failure-mode analysis after the owner is already known | `ai_navigation/failure_modes.md` |
| symptom-first bug report | `ai_navigation/debug_routes.md` |
| runtime error to diagnose or fix | `ai_navigation/runtime_errors.md` |
| qdel, del, Destroy(), ref leak | `ai_navigation/runtime_errors.md` §qdel → `ai_navigation/coding_standards.md` §GC |
| overlays, underlays, Appearance objects, per-tick visuals, planes, filters, particles, lighting, animate(), render relays, multiz | `ai_navigation/visuals_guide.md` |
| GAGS, greyscale sprites, recolorable item or mob, greyscale_config, greyscale_colors | `ai_navigation/visuals_guide.md` §GAGS |
| performance, tick budget, CPU, server lag | `ai_navigation/engine_limits.md` → `ai_navigation/performance_gotchas.md` |
| code style, signal pattern, GC, harddel, CI, walk procs, delta-time | `ai_navigation/coding_standards.md` |
| reagents, chemistry, holder, reagent container, splash | `code/modules/reagents/**` — start with `chemistry/holder.dm` and `chemistry/readme.md` |
| TGUI interface, ui_interact, ui_data, ui_act, React component | `ai_navigation/tgui_guide.md` |
| keyword or feature-name routing | `ai_navigation/entrypoints.md` |
| BYOND type path `/datum/...` `/mob/...` `/obj/...` | `ai_navigation/type_index.md` |
| lifecycle, timing, scheduler, round flow | `ai_navigation/runtime_flow.md` |
| cross-system handoff or dependency | `ai_navigation/system_dependencies.md` |
| explicit `SS*` subsystem | `ai_navigation/subsystem_map.md` |
| unknown architecture or location | `ai_navigation/system_map.md` or `ai_navigation/architecture.md` |
| modular_rmh layer, where RMH code lives, overlay rules | `ai_navigation/modular_guide.md` |
| deep inheritance | `ai_navigation/type_tree.md` — search specific path, do not read whole file |
| budget rules, engine constraints detail | `ai_navigation/router_deep.md` |

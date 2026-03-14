# Router

Fast Start entrypoint. Navigation layer may lag ~1 month behind code — use for routing, verify in source.

## Always

| When | Action |
|---|---|
| before any medium / high / unclear-scope edit | open `ai_navigation/human_checking.md` first |

## Dispatch

| Task | Helper |
|---|---|
| broad, risky, or needs approval before edits | `ai_navigation/human_checking.md` |
| refresh or migrate the navigation layer | `ai_navigation/update_policy.md` |
| new mechanic, content, or feature extension | `ai_navigation/content_creation.md` |
| vague content — needs decomposition | `ai_navigation/content_breakdown.md` |
| content goal clear, implementation form undecided | `ai_navigation/content_patterns.md` |
| signals, components, indirect event routing | `ai_navigation/signal_map.md` |
| spell, miracle, cooldown action | `ai_navigation/spell_signal_map.md` |
| melee, projectile, hit, disarm, combat chain | `ai_navigation/combat_signal_map.md` |
| movement, collision, buckle, pull, throw, moveloop | `ai_navigation/movement_signal_map.md` |
| proc entrypoints before searching source | `ai_navigation/core_procs.md` |
| subsystem/loop freezes, hangs, no runtimes | `ai_navigation/processing_hazards.md` |
| performance, tick budget, CPU, server lag | `ai_navigation/engine_limits.md` → `ai_navigation/performance_gotchas.md` |
| overlays, underlays, Appearance objects, per-tick visuals | `ai_navigation/visuals_guide.md` + `ai_navigation/performance_gotchas.md` §7 |
| planes, filters, particles, lighting, animate(), GAGS, render relays, multiz | `ai_navigation/visuals_guide.md` |
| code style, signal pattern, GC, harddel, CI, walk procs, delta-time | `ai_navigation/coding_standards.md` |
| failure-mode analysis, owner already known | `ai_navigation/failure_modes.md` |
| symptom-first bug report | `ai_navigation/debug_routes.md` |
| runtime error to diagnose or fix | `ai_navigation/runtime_errors.md` |
| qdel, del, Destroy(), ref leak | `ai_navigation/runtime_errors.md` §qdel → `ai_navigation/coding_standards.md` §GC |
| TGUI interface, ui_interact, ui_data, ui_act, React component | `ai_navigation/tgui_guide.md` |
| keyword or feature-name routing | `ai_navigation/entrypoints.md` |
| BYOND type path `/datum/...` `/mob/...` `/obj/...` | `ai_navigation/type_index.md` |
| lifecycle, timing, scheduler, round flow | `ai_navigation/runtime_flow.md` |
| cross-system handoff or dependency | `ai_navigation/system_dependencies.md` |
| explicit `SS*` subsystem | `ai_navigation/subsystem_map.md` |
| unknown architecture or location | `ai_navigation/system_map.md` or `ai_navigation/architecture.md` |
| deep inheritance | `ai_navigation/type_tree.md` — search specific path, do not read whole file |
| budget rules, engine constraints detail | `ai_navigation/router_deep.md` |

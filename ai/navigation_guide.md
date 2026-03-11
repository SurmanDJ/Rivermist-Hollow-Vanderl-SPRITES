# Navigation Guide for Future AI Agents

Use this guide to avoid rescanning the whole repository when a task can be localized quickly.

If you are framing a new task for an agent, use `ai/task_templates.md` together with this guide.

## Read Order

1. Start with exactly one small helper file:
   - `ai/entrypoints.md` for keyword or feature-name routing
   - `ai/debug_routes.md` for symptom-first debugging
   - `ai/type_index.md` for BYOND type paths
   - `ai/runtime_flow.md` for lifecycle/order/tick questions
   - `ai/system_dependencies.md` for cross-system handoffs
2. Open up to 2 source files for that route.
3. Escalate only if the route is still ambiguous:
   - `ai/system_map.md`
   - `ai/subsystem_map.md`
   - `ai/architecture.md`
   - `ai/type_tree.md`

## Read Budget

- Stage 1: one small helper file + up to 2 source files.
- Stage 2: one more helper file or one `SS*` file + up to 2 more source files.
- Stage 3: only then open the larger maps or do broader searches.

## Fast Routing Rules

- If a keyword in `ai/entrypoints.md` already matches the task, use that route before opening the larger maps.
- If the task begins with a symptom, use `ai/debug_routes.md` before anything else.
- If the task gives a BYOND type path, use `ai/type_index.md` before `ai/type_tree.md`.
- If you know the systems but not their handoff, use `ai/system_dependencies.md` before opening more source files.
- If you know the symptom is timing/order related, use `ai/runtime_flow.md` before doing a broad search.
- Unknown type path: search the exact path in `ai/type_index.md`; use `ai/type_tree.md` only if inheritance depth is the issue.
- `SS*` subsystem mention: find the global in `ai/subsystem_map.md`; open the mapped file in `code/controllers/subsystem/**` and then inspect any type roots it schedules.
- Jobs, classes, spawn roles: inspect `code/modules/jobs/**`, `code/datums/migrants/**`, then `modular_rmh/code/modules/jobs/**` for RMH-specific roles and subclasses.
- Spells, actions, status effects: inspect `code/modules/spells/**`, `code/datums/status_effects/**`, `code/datums/components/**`, `code/datums/elements/**`, then the parallel RMH paths in `modular_rmh/`.
- AI and NPC behavior: inspect `code/datums/ai/**`, then the AI-related entries in `ai/subsystem_map.md`, then any mob-specific files in `code/modules/mob/**` or `modular_rmh/code/modules/mob/**`.
- Worldgen, maps, dungeons, voyage: inspect `_maps/**`, `code/modules/mapping/**`, `code/modules/procedural_mapping/**`, and the mapping-related subsystem files (`mapping.dm`, `minor_mapping.dm`, `dungeon_generator.dm`, `voyage.dm`).
- Economy, property, regional simulation: inspect economy + treasury + property-management subsystems, then `code/datums/world_factions/**`, `code/datums/nation/**`, and `code/datums/rts/**` if the issue is strategic or settlement-related.
- UI, browser, tgui work: inspect `code/modules/tgui/**`, `code/modules/visual_ui/**`, `interface/**`, and `tgui/packages/**` together; DM and TS halves are usually paired.
- Modular behavior suspicion: after finding a core path, always check `modular_rmh` for descendants on the same type branch or late-included content that reuses the same subsystem.

## Suggested Search Patterns

- Exact type path: `rg -n "^/datum/status_effect" code modular_rmh -g "*.dm"`
- All subsystem declarations: `rg -n "^(SUBSYSTEM_DEF|PROCESSING_SUBSYSTEM_DEF|TIMER_SUBSYSTEM_DEF|MOVEMENT_SUBSYSTEM_DEF|AI_CONTROLLER_SUBSYSTEM_DEF|VERB_MANAGER_SUBSYSTEM_DEF)\(" code/controllers/subsystem -g "*.dm"`
- Any `SS*` call site: `rg -n "\bSS[A-Z][A-Za-z0-9_]*\b" code modular_rmh -g "*.dm"`
- Component hooks: `rg -n "\bAddComponent\(" code modular_rmh -g "*.dm"`
- Status effect application: `rg -n "\bapply_status_effect\(" code modular_rmh -g "*.dm"`
- Map/template references: `rg -n "map_template|map_load_mark|map_adjustment" code _maps modular_rmh -g "*.dm"`
- AI paths: `rg -n "^/datum/ai_(controller|behavior)" code modular_rmh -g "*.dm"`

## Heuristics That Save Time

- Prefer one helper file plus source files over multiple helper files in a row.
- Prefer directory families over whole-repo scans: `code/datums` for logic/state, `code/modules` for feature slices, `code/game` for concrete world objects.
- If a system is content-heavy, inspect `modular_rmh` early; if it is scheduler/runtime-heavy, inspect `code/controllers` first.
- When behavior feels indirect, assume signals/components are involved and search DCS hooks before tracing every proc call by hand.
- When an issue is round-start or lifecycle related, always open `code/world.dm`, `code/controllers/master.dm`, and the relevant `SS*` entry before diving into content files.

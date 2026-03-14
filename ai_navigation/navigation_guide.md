# Navigation Guide

Supplementary reference. Use only after `router.md` dispatch — do not open as a first step.

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
- Prefer `Fast Start` unless a heavier startup mode is justified.
- Prefer directory families over whole-repo scans: `code/datums` for logic/state, `code/modules` for feature slices, `code/game` for concrete world objects.
- If a system is content-heavy, inspect `modular_rmh` early; if it is scheduler/runtime-heavy, inspect `code/controllers` first.
- Before editing anything broad, classify risk and ask for approval if the scope is medium, high, or ambiguous.
- For navigation-layer refreshes, rebuild runtime ownership and routing layers before deep reference layers.
- For migration work, preserve the navigation model, not this repo's exact paths.
- For new content, minimize host scope first and minimize trigger frequency second.
- For new content, decompose delivery/base/delta/effect before choosing code shape.
- For new content, prefer an existing implementation pattern before designing a new abstraction.
- For indirect behavior, check signals and core proc families before doing a broad code walk.
- For spells and similar cooldown-action systems, check the spell signal contract before doing a broad DCS walk.
- For combat and hit chains, check the combat signal contract before walking individual weapons or mobs.
- For player or looped movement, check the movement signal contract before broad searches through mob code.
- If a shared subsystem silently stalls, check for blocking calls before assuming scheduler pressure.
- If ownership is clear but cause is not, classify the failure mode before tracing more code.
- When behavior feels indirect, assume signals/components are involved and search DCS hooks before tracing every proc call by hand.
- When an issue is round-start or lifecycle related, always open `code/world.dm`, `code/controllers/master.dm`, and the relevant `SS*` entry before diving into content files.

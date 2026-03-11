# Debug Routes

Generated on 2026-03-11. Use this file when the task starts from a symptom instead of a known file, type path, or subsystem.

## Symptom-First Routes

| Symptom | Open first | Then check | Runtime owner(s) |
|---|---|---|---|
| Antagonist does not spawn, wrong villain, missing thralls | `ai/runtime_flow.md` (round flow), `code/modules/events/antagonist/**`, `code/modules/antagonists/**` | `code/datums/migrants/waves/antagonist/**`, map landmarks/spawn points, `ai/subsystem_map.md` | `SSticker`, `SSgamemode`, `SSevents` |
| Spell button works poorly or spell does nothing | `ai/runtime_flow.md` (action/spell flow), `code/modules/spells/spell.dm`, specific spell file | `code/datums/status_effects/**`, `code/datums/components/**`, `code/datums/elements/**` | `SSmagic`, `SSstatusprocess`, `SSskills` |
| Status effect applies then disappears or never ticks | `code/datums/status_effects/**`, `ai/runtime_flow.md` | components/elements, signal hooks, spell/action caller | `SSstatusprocess`, sometimes `SSmagic` |
| NPC is idle, stuck, or chooses the wrong target | `code/datums/ai/**`, `ai/runtime_flow.md` (AI flow) | `code/controllers/subsystem/processing/ai_behaviors.dm`, `ai_movement.dm`, mob-specific files | `SSai_controllers`, `SSai_behaviors`, `SSai_movement` |
| Player gets wrong role, wrong loadout, or latejoin is broken | `code/modules/jobs/**`, `code/datums/migrants/**`, `ai/runtime_flow.md` (role/job flow) | `modular_rmh/code/modules/jobs/**`, `SSrole_class_handler`, spawn landmarks | `SSjob`, `SSmigrants`, `SSrole_class_handler` |
| UI opens, but values are wrong or stale | `code/modules/tgui/**`, `code/modules/visual_ui/**`, `tgui/packages/**` | underlying gameplay datum/mob, status/components, browser handlers | `SStgui`, `SSvisual_ui`, `SSchat` |
| Roundstart/startup/runtime order looks wrong | `code/world.dm`, `code/controllers/master.dm`, `ai/runtime_flow.md`, `ai/subsystem_map.md` | target subsystem file and its `fire()/Initialize()` path | `Master`, target `SS*` |
| Map landmark is missing or wrong place is used | `_maps/**`, `code/modules/mapping/**`, `ai/runtime_flow.md` (mapping flow) | landmark type path, event/job consumer, procedural mapgen | `SSmapping`, `SSminor_mapping`, `SSdungeon_generator` |
| Feature changes state indirectly and there is no obvious proc chain | `code/datums/components/**`, `code/datums/elements/**`, `ai/runtime_flow.md` (signal path) | `code/__DEFINES/dcs/**`, original caller via `SEND_SIGNAL` | `SSdcs` plus the owning feature subsystem |
| Lag, hitching, runaway processing, or MC pressure | `ai/subsystem_map.md`, `ai/runtime_flow.md`, owner subsystem file | hot feature files, signal/component hotspots, high-frequency loops | target `SS*`, `Master` |

## Cheap Debugging Rules

- Pick one route row first. Do not open `ai/system_map.md` unless the symptom still does not localize.
- Once the owner subsystem is known, switch from maps to source files quickly.
- If a symptom obviously maps to a BYOND type path, use `ai/type_index.md` instead.
- After finding the core implementation, always check the same branch in `modular_rmh`.

# Entrypoints

Generated on 2026-03-11. Use this file before the larger maps when the goal can be matched to a known system quickly.

## Minimal Route

1. Match the task to one row below.
2. Open only the listed directories/files first.
3. Escalate only if needed:
   - symptom-first debugging -> `ai/debug_routes.md`
   - handoff between systems unclear -> `ai/system_dependencies.md`
   - execution order/lifecycle unclear -> `ai/runtime_flow.md`
   - ownership unclear -> `ai/subsystem_map.md`
   - system unclear -> `ai/system_map.md`
   - branch/root unclear for a type path -> `ai/type_index.md`
   - deep inheritance unclear -> `ai/type_tree.md`
   - architecture/layer question -> `ai/architecture.md`

## Fast Index

| Task or keyword | Open first | Then check | Runtime owner |
|---|---|---|---|
| `vampire`, `werewolf`, `antag`, `thrall`, `villain` | `code/modules/antagonists/**` | `code/modules/events/antagonist/**`, `code/datums/migrants/waves/antagonist/**`, `modular_rmh/**` | `SSgamemode`, `SSevents` |
| `job`, `role`, `latejoin`, `spawn role`, `migrant`, `class` | `code/modules/jobs/**`, `code/datums/migrants/**` | `modular_rmh/code/modules/jobs/**`, `code/modules/mob/**` | `SSjob`, `SSmigrants`, `SSrole_class_handler` |
| `spell`, `ability`, `action`, `status`, `buff`, `debuff` | `code/modules/spells/**`, `code/datums/status_effects/**` | `code/datums/components/**`, `code/datums/elements/**`, `modular_rmh/code/modules/spells/**` | `SSmagic`, `SSstatusprocess`, `SSskills` |
| `ai`, `npc`, `behavior`, `controller`, `hostile mob` | `code/datums/ai/**`, `code/modules/mob/**` | `modular_rmh/code/datums/ai/**`, `modular_rmh/code/modules/mob/**` | `SSai_controllers`, `SSai_behaviors`, `SSai_movement` |
| `map`, `dungeon`, `voyage`, `worldgen`, `template`, `spawn landmark` | `_maps/**`, `code/modules/mapping/**`, `code/modules/procedural_mapping/**` | `modular_rmh/code/game/modules/mapgen/**`, landmarks/spawners on the affected branch | `SSmapping`, `SSminor_mapping`, `SSdungeon_generator`, `SSterrain_generation` |
| `economy`, `merchant`, `treasury`, `property`, `housing`, `faction` | `code/modules/economy/**` | `code/controllers/subsystem/economy.dm`, `treasury.dm`, `property_management.dm`, `code/datums/world_factions/**` | `SSeconomy`, `SStreasury`, `SShousing`, `SSmerchant` |
| `craft`, `recipe`, `material`, `runeword`, `anvil`, `fishing`, `farming` | `code/modules/crafting/**`, `code/datums/materials/**`, `code/datums/runeword/**` | `code/modules/farming/**`, `code/modules/fishing/**`, `code/datums/quality/**` | `SSskills`, `SSanvil`, `SSfishing`, `SSenchantment` |
| `faith`, `god`, `mana`, `quirk`, `wound`, `stress`, `mood` | `code/datums/faith/**`, `code/datums/gods/**`, `code/datums/mana/**` | `code/datums/quirks/**`, `code/datums/wounds/**`, RMH datums | `SSskills`, `SSstatusprocess`, `SSmood` |
| `liquid`, `weather`, `fire`, `overlay`, `lighting` | `code/datums/liquids/**`, `code/datums/particle_weathers/**` | `code/controllers/subsystem/liquids.dm`, `particle_weather*.dm`, fire/overlay subsystems | `SSliquids`, `SSParticleWeather`, `SSfire_burning`, `SSfire_spread`, `SSlighting` |
| `tgui`, `ui`, `browser`, `hud`, `interface` | `code/modules/tgui/**`, `code/modules/visual_ui/**`, `interface/**` | `tgui/packages/**`, `html/**` | `SStgui`, `SSvisual_ui`, `SSchat` |
| `lag`, `runtime`, `processing`, `tick`, `scheduler`, `master`, `startup` | `ai/subsystem_map.md`, `code/world.dm`, `code/controllers/master.dm`, `code/controllers/subsystem.dm` | `code/controllers/subsystem/**`, `rg` for the relevant `SS*` | `Master`, target `SS*` |
| exact BYOND type path like `/datum/...`, `/mob/...`, `/obj/...` | `ai/type_index.md` | matching DM branch in `code/**` and `modular_rmh/**`, then `ai/type_tree.md` if needed | depends on branch |

## Escalation Rules

- If a keyword row matches, do not open `ai/system_map.md` immediately.
- If the user gives a symptom instead of a feature name, switch to `ai/debug_routes.md`.
- If the first branch is wrong, switch rows once before doing a broad repository search.
- After locating a core path in `code/`, always check whether `modular_rmh` extends the same branch.

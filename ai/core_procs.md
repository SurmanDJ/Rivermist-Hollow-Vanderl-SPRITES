# Core Procs

Generated on 2026-03-11. Use this file to keep the main proc families and entry hooks in mind before doing a broad search.

## Lifecycle Procs

These are common first entrypoints for object and datum behavior:

- `New`
- `Initialize`
- `Destroy`
- `qdel`

Use these when behavior appears on creation, mapload, cleanup, or deletion.

## Interaction Procs

These are common gameplay hook points:

- `attack_self`
- `pre_attack`
- `attackby`
- `afterattack`
- `ui_interact`
- `Topic`

Use these when a feature happens because a player clicked, used, or targeted something.

## Movement And Physics Hooks

- `Moved`
- `Crossed`
- `Bump`

Use these when behavior follows stepping, transit, collision, or turf/object movement.

## Timed And Status Hooks

- `process`
- `tick`
- `on_apply`
- `on_remove`

Use these when a feature is periodic, temporary, or stateful.

## Scheduler Hooks

- subsystem `fire`
- `START_PROCESSING`
- `STOP_PROCESSING`
- `addtimer`

Use these when runtime ownership, periodic updates, or delayed effects matter.

## DCS And Indirect Hooks

- `RegisterSignal`
- `SEND_SIGNAL`
- `UnregisterSignal`

Use these when behavior is component-driven or the visible cause is far from the actual logic.

## Fast Search Patterns

- lifecycle:
  `rg -n "/(Initialize|Destroy|New)\(" code modular_rmh -g "*.dm"`
- interaction:
  `rg -n "/(attack_self|attackby|afterattack|ui_interact|Topic)\(" code modular_rmh -g "*.dm"`
- timed/state:
  `rg -n "/(process|tick|on_apply|on_remove)\(" code modular_rmh -g "*.dm"`
- scheduler:
  `rg -n "\b(addtimer|START_PROCESSING|STOP_PROCESSING)\b" code modular_rmh -g "*.dm"`

## Rule Of Thumb

- If it happens on creation, start with `Initialize`.
- If it happens on use, start with interaction procs.
- If it happens over time, start with `process` or `tick`.
- If it feels indirect, switch immediately to `ai/signal_map.md`.

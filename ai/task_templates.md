# Task Templates

These are copy-paste templates for giving agents better task briefs in this repository.

Use them when you want the agent to start cleanly, avoid broad scans, and route itself through the `ai/` maps.

## 1. Minimal Fast Task

Use when you already know the system and want the shortest workable brief.

```text
Goal:
<what should be fixed / changed / explained>

Context:
<type path / SS* / directory / feature name>

Constraints:
<what not to touch>

Verification:
<what must be true in the end>

Repository guidance:
Start with AGENTS.md and ai/entrypoints.md, then open ai/system_dependencies.md or ai/runtime_flow.md only if the task crosses systems or depends on lifecycle/order.
```

## 2. Bugfix Template

Use for a gameplay or runtime bug when you want analysis plus a concrete fix.

```text
Goal:
Fix a bug in <feature/system>.

Where to start:
<type path / subsystem / likely directory>

Symptoms:
- <what the player/admin sees>
- <when it happens>

Reproduction:
1. <step>
2. <step>
3. <bad result>

Expected behavior:
- <correct result>

Constraints:
- Keep the fix minimal.
- Do not refactor unrelated systems.
- Check whether modular_rmh extends the same path.

Verification:
- Confirm the reproduced scenario now behaves correctly.
- Mention which files and runtime owners were involved.

Repository guidance:
Start with AGENTS.md and ai/entrypoints.md, then use ai/system_dependencies.md, ai/runtime_flow.md, and ai/subsystem_map.md only if the bug crosses systems or depends on runtime ownership.
```

## 3. New Feature Template

Use when adding a mechanic, new content, or an extension to an existing system.

```text
Goal:
Add <new feature>.

Target system:
<jobs / spells / status effects / AI / mapping / economy / etc.>

Expected shape:
- New type path(s): <if known>
- User-facing behavior: <what the player/admin sees>
- Runtime owner: <if known; e.g. SSmagic, SSmigrants, SSmapping>

Constraints:
- Reuse existing patterns in this repo.
- Prefer extending the existing type tree over inventing a parallel system.
- Check whether the change belongs in core code or in modular_rmh.

Verification:
- Describe how to trigger the feature.
- Describe what success looks like.

Repository guidance:
Start with AGENTS.md, then ai/entrypoints.md; add ai/system_dependencies.md, ai/system_map.md, and ai/type_tree.md if the feature touches multiple branches.
```

## 4. Refactor / Cleanup Template

Use when the behavior should remain the same but the code needs cleanup.

```text
Goal:
Refactor <module/system> without changing behavior.

Current location:
<directory / type path / subsystem>

Why:
- <duplication / readability / dead code / coupling / maintenance>

Constraints:
- No gameplay changes.
- No balance changes.
- Keep public behavior stable.
- Call out any risky behavior-preserving assumptions.

Verification:
- Explain how you confirmed behavior is unchanged.
- Mention any residual risk.

Repository guidance:
Start with AGENTS.md, then ai/entrypoints.md; add ai/system_dependencies.md, ai/architecture.md, and ai/system_map.md as needed.
```

## 5. Architecture / Investigation Template

Use when you want explanation, root-cause analysis, or a plan before editing.

```text
Goal:
Analyze how <system> works.

Focus:
- <runtime flow / ownership / inheritance / dependency map / extension points>

Known anchors:
- <type path / SS* / directory / user scenario>

Output needed:
- <explanation / root cause / implementation plan / file map>

Constraints:
- No code changes unless explicitly approved.

Repository guidance:
Start with AGENTS.md and use ai/entrypoints.md, ai/system_dependencies.md, ai/runtime_flow.md, ai/architecture.md, ai/system_map.md, ai/subsystem_map.md, and ai/type_tree.md as needed.
```

## 6. Code Review Template

Use when you want findings instead of implementation.

```text
Goal:
Review <change / branch / files> for bugs, risks, regressions, and missing tests.

Scope:
<paths / feature area / subsystem>

Review focus:
- correctness
- runtime ownership
- inheritance / type tree fit
- subsystem interactions
- modular_rmh overlap

Constraints:
- Findings first.
- Keep summary brief.
- Do not rewrite code unless asked.

Repository guidance:
Start with AGENTS.md and use ai/entrypoints.md, ai/system_dependencies.md, ai/system_map.md, plus ai/subsystem_map.md for ownership.
```

## 7. Runtime / Performance Template

Use for lag, MC pressure, processing, or scheduler issues.

```text
Goal:
Investigate runtime/performance issue in <system>.

Known anchors:
- subsystem: <SS* if known>
- feature: <what was happening>
- symptom: <lag / hitching / runtime / runaway processing>

What to determine:
- who owns runtime execution
- where the hot path lives
- whether the issue is in scheduling, signals, or high-frequency processing

Constraints:
- Prioritize identifying the owner and the narrowest hot path.

Repository guidance:
Start with AGENTS.md, then ai/entrypoints.md, ai/runtime_flow.md, ai/subsystem_map.md, and ai/architecture.md.
```

## 8. Content / Data Template

Use for jobs, outfits, spells, map templates, or gameplay data additions.

```text
Goal:
Add or modify content for <jobs / outfits / spells / map template / migrant wave / antagonist / status effect>.

Likely location:
<type path / directory>

Desired result:
- <new content>
- <availability / unlock condition / trigger>

Constraints:
- Follow existing content conventions.
- Keep balance and role gating in mind.
- Check both core and modular_rmh before adding a duplicate branch.

Verification:
- Explain how the new content is reached or spawned.

Repository guidance:
Start with AGENTS.md, then ai/entrypoints.md, ai/type_tree.md, and ai/system_map.md; add ai/system_dependencies.md if the content branches into other systems.
```

## Recommended Human Workflow

If you want a future agent to work well from the first turn, do this:

1. Send the goal using one of the templates above.
2. Then send the repository and tell the agent to start with `AGENTS.md`.

That matches the intended operating model for this repository:

1. Here is the goal.
2. Here is the repository with guidance.

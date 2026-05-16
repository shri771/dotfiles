# Agent Runbook Template

This repo is a user-level configuration or codebase deployed to a known runtime location.

Replace the placeholders below with repo-specific facts.

## Files That Matter

- `<file/path>`: `<what changes here>`
- `<file/path>`: `<what changes here>`
- `<file/path>`: `<what changes here>`

## Exact Change Points

### Add or change a keybinding / command / entrypoint

Edit `<file/path>`.

Examples:

- `<example mapping or command>`
- `<example mapping or command>`

Rules:

- State the exact syntax used in this repo.
- State whether deployed paths must be absolute or relative.
- State where dependent commands must be defined first.

### Add or change a preview / renderer / processing rule

Edit `<file/path>`.

Actual execution order:

1. `<step 1>`
2. `<step 2>`
3. `<step 3>`

Use:

- `<handler/function/path>` when `<condition>`
- `<handler/function/path>` when `<condition>`

Exit codes or return behavior:

- `<code/value>`: `<meaning>`
- `<code/value>`: `<meaning>`

Example:

`<State exactly where this kind of feature belongs and why.>`

### Add a custom command / feature

Small change:

- Add or import it via `<file/path>`.

Standalone feature:

- Put it in `<directory or module>`.

Rules:

- `<error handling rule>`
- `<dependency lookup rule>`
- `<selection/current-item handling rule>`

### Add a helper script / utility

Put it in `<directory>`.

Rules:

- `<shebang rule>`
- `<shell safety rule>`
- `<must be runnable outside host app: yes/no>`

## Current External Dependencies

Required by current config/code:

- `<tool/package>`: `<why>`
- `<tool/package>`: `<why>`

Referenced but not vendored in this repo:

- `<module/plugin/package>`

Optional runtime helpers:

- `<tool/package>`: `<why>`

## Precise Debug Flow

### Keybinding / command issue

Check `<file/path>`.

Questions:

- Does the mapping or command exist?
- Does it call the correct path or function?
- Does the target command/script/module exist?

### Preview / render / processing issue

Check `<file/path>`.

Run:

```bash
<exact local reproduction command>
```

Then verify:

```bash
<syntax check command>
<dependency check command>
<type or metadata inspection command>
```

Interpretation:

- `<signal/result>`: `<meaning>`
- `<signal/result>`: `<meaning>`

If the expected output does not appear:

- Confirm `<setting or flag>`
- Confirm `<runtime dependency>`
- Confirm `<generated artifact/cache/output>` is written

### Python / plugin / module issue

Run:

```bash
<compile/lint/import check command>
```

Then check:

- missing imports
- missing binaries or packages
- wrong deployment path or runtime location

### Shell helper script issue

Run directly:

```bash
<script invocation>
```

If it fails, debug the script first, not the host application.

## Issue Tracking Format

Use this exact structure when investigating or fixing a problem.

### Issue

One sentence stating the user-visible failure.

Template:

`<Thing> does not <expected behavior> in <location/context>.`

### Impact

One sentence stating what is broken and where.

Template:

`When <condition>, <user-facing failure>.`

### Root Cause

State the precise failing condition.

Template:

`<file/component> did <incorrect behavior> because <specific condition or missing path>.`

### Fix

State the exact code or config change.

Template:

`Changed <file/component> to <specific implementation change>.`

### Why This Works

State the execution-path reason, not just the symptom.

Template:

`<function/path/order/condition> now causes <correct behavior> before/after <previous failing behavior>.`

### Verification

List the exact checks run.

Template:

- `<command>`
- `<command>`
- `<manual verification step>`

## Change Rules

- Make the smallest change that fixes the issue.
- Prefer the existing extension point over adding a second parallel mechanism.
- Preserve deployment assumptions unless deployment is part of the task.
- Do not remove external references unless you verified they are unused in the live runtime.

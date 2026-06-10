For version control history and _local_ repo ops: default to `jj`, not `git`, unless not easily doable with `jj`.

For _GitHub_ (remote): always use `gh` CLI. **Never perform any write operations with `gh` CLI** (e.g. `gh pr create`, `gh pr merge` etc.) without being explicitly asked to or asking for approval first.

**Never move `@`.** Trashes build caches. Never commit, squash, rebase, or otherwise do any write operations to the commit graph, unless explicitly asked to.

Forbidden: `git push`, `jj git push`, `jj edit`, `jj checkout`, `jj prev`, `jj next`, `jj new <rev>` without `--no-edit`, `git checkout`, `git switch`, `git reset --hard`.

Workflow:

- Edit in `@`.
- User will commit/squash/rebase as needed, then ask for further edits.
- Further edits still go in the new `@`.

Inspect without moving: `jj log -r <rev>`, `jj show <rev>`, `jj diff --from <a> --to <b>`, `jj file show -r <rev> <path>`.

Show current uncommitted diffs of `@`: `jj show`

If op would move `@`, stop and ask first.

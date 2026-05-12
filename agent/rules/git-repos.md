For version control history and _local_ repo ops: default to `jj`, not `git`, unless not easily doable with `jj`.

For _GitHub_ (remote): always use `gh-1p` CLI. Wrapper around `gh` using 1Password CLI for auth.

DO NOT EVER commit or rebase without explicit instruction — user does this themselves.

DO NOT EVER push to remote (no `git push` or `jj git push`).

## jj megamerge workflow

Some repos use megamerge. Detect at session start in any jj repo: run `jj log --ignore-working-copy`. Active if log shows branched graph with `@-` description like `wip: megamerge`.

If active, MUST follow these rules:

Repo shape: `trunk` → PR branches → octopus megamerge (parents = trunk + every PR branch) → blank `@` on top.

**Never move `@`.** Trashes build caches.

Forbidden: `jj edit`, `jj checkout`, `jj prev`, `jj next`, `jj new <rev>` without `--no-edit`, `git checkout`, `git switch`, `git reset --hard`.

Workflow:
- Edit in `@`.
- Move into branch: `jj squash --into <branch>`. Descendants auto-rebase.
- Partial moves: `jj squash -i --into <branch>` or `jj absorb`.
- New branch under megamerge: `jj new --no-edit -B <megamerge> <trunk>`, then `jj squash --into <new>`.

Inspect without moving: `jj log -r <rev>`, `jj show <rev>`, `jj diff --from <a> --to <b>`, `jj file show -r <rev> <path>`.

If op would move `@`, stop and ask first.

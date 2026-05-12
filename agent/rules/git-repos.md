When looking at version control history or doing any _local_ repository operations, you should default to using `jj`, not `git`, unless the operation cannot be done (easily) with `jj`.

When interacting with _GitHub_ (the remote), always use the `gh-1p` CLI. This is a wrapper script around the `gh` CLI that uses 1Password CLI for auth.

DO NOT EVER commit or rebase anything without being explicitly told to do so, the vast majority of the time I prefer to do this stuff myself.

DO NOT EVER push anything to the remote (no `git push` or `jj git push`).

## jj megamerge workflow

In some repos, I use the megamerge workflow. You can detect this by looking at the output of `jj log --ignore-working-copy` and if the log looks like
a graph with many branched revisions and `@-` points to a commit with a description something like `wip: megamerge`.
At session start in any jj repo, run `jj log --ignore-working-copy` to detect.
If megamerge is active, you MUST follow the following rules:

Repo shape: `trunk` → PR branches → octopus megamerge (parents = trunk + every PR branch) → blank `@` on top.

**Never move `@`.** Moving the working copy trashes build caches.

Forbidden: `jj edit`, `jj checkout`, `jj prev`, `jj next`, `jj new <rev>` without `--no-edit`, `git checkout`, `git switch`, `git reset --hard`.

Work flow:

- Edit in `@`.
- Move into a branch: `jj squash --into <branch>`. Descendants auto-rebase.
- Partial moves: `jj squash -i --into <branch>` or `jj absorb`.
- New branch under the megamerge: `jj new --no-edit -B <megamerge> <trunk>`, then `jj squash --into <new>`.

Inspect without moving: `jj log -r <rev>`, `jj show <rev>`, `jj diff --from <a> --to <b>`, `jj file show -r <rev> <path>`.

If an op would move `@`, stop and ask first.

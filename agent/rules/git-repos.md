When looking at version control history or doing any _local_ repository operations, you should default to using `jj`, not `git`, unless the operation cannot be done (easily) with `jj`.

When interacting with _GitHub_ (the remote), always use the `gh-1p` CLI. This is a wrapper script around the `gh` CLI that uses 1Password CLI for auth.

#!/usr/bin/env bash

if test "$#" -ne 0; then
  git checkout "$@"
else
  git branch -a --format="%(refname:short)" | sed 's|origin/||g' | grep -v "HEAD" | sort | uniq | fzf-tmux -p -x 15 | xargs git checkout
fi

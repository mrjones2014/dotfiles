#!/usr/bin/env bash

if test "$#" -ne 0; then
  if [[ "$*" = "master" ]] || [[ "$*" = "main" ]]; then
    git checkout "$(git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n1)"
  else
    git checkout "$@"
  fi
else
  git branch -a --format="%(refname:short)" | sed 's|origin/||g' | grep -v "HEAD" | sort | uniq | fzf-tmux -p -x 15 | xargs git checkout
fi

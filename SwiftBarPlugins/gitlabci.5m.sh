#!/usr/bin/env bash

source $HOME/SwiftBarPlugins/gitlab-ci-plugin-vars;

getGitlabUrl() {
  REMOTE_URL=`git config --get remote.origin.url`;
  if [[ $REMOTE_URL == *"$GITLAB_BASE_URL"* ]]; then
    PROJECT_PATH=`git config --get remote.origin.url | sed 's/^ssh.*@[^/]*\(\/.*\).git/\1/g'`
    GITLAB_URL="https://$GITLAB_BASE_URL$PROJECT_PATH"
    echo $GITLAB_URL;
  fi
}

echo "GitLab CI"
echo "---"

pushd $HOME/git > /dev/null;
repos=$(ls 2>&1);

for repo in $repos; do
  pushd $repo > /dev/null;
  remote="$(getGitlabUrl)"
  if [[ $remote == *"$GITLAB_BASE_URL"* ]]; then
    echo $repo;
    echo "--View Pipelines | href=$remote/-/pipelines"
    echo "--New Pipeline | href=$remote/-/pipelines/new"
  fi
  popd > /dev/null;
done;
popd > /dev/null;

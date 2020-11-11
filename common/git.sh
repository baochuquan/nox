#!/bin/bash

# Outputs the name of the current branch
function git_current_branch() {
  local ref
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Gets the number of commits ahead from remote
function git_commits_ahead() {
  if git rev-parse --git-dir &>/dev/null; then
    local commits="$(git rev-list --count @{upstream}..HEAD 2>/dev/null)"
    echo "commits = $commits"
    if [[ -n "$commits" && "$commits" != 0 ]]; then
      echo "$commits"
    fi
  fi
}

# Gets the number of commits behind remote
function git_commits_behind() {
  if git rev-parse --git-dir &>/dev/null; then
    local commits="$(git rev-list --count HEAD..@{upstream} 2>/dev/null)"
    if [[ -n "$commits" && "$commits" != 0 ]]; then
      echo "$commits"
    fi
  fi
}

# Outputs if current branch is ahead of remote
function git_prompt_ahead() {
  if [[ -n "$(git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]; then
    echo "ahead"
  fi
}

# Outputs if current branch is behind remote
function git_prompt_behind() {
  if [[ -n "$(git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]; then
    echo "behind"
  fi
}

# Outputs if current branch exists on remote or not
function git_prompt_remote() {
  if [[ -n "$(git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]; then
    echo "exists"
  else
    echo "missing"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  local SHA
  SHA=$(git rev-parse --short HEAD 2> /dev/null) && echo "$SHA"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  local SHA
  SHA=$(git rev-parse HEAD 2> /dev/null) && echo "$SHA"
}

#!/usr/bin/env bash
# Prints the app version, YY.M.N (e.g. 26.10.7): the year and month of the latest
# commit, then the number of commits made that month. Every deploy follows a new
# commit, so the version goes up by itself; nothing to edit by hand, and the same
# commit always gives the same version.
set -euo pipefail
repo="$(cd "$(dirname "$0")/../../.." && pwd)"

# CI and Render clone shallowly, which would undercount (Render showed 26.10.1 for
# every build). Fetch the full history from origin, then from the public GitHub URL.
if [[ "$(git -C "$repo" rev-parse --is-shallow-repository 2>/dev/null)" == true ]]; then
  echo "app-version: shallow clone, fetching full history" >&2
  sources=(origin)
  [[ -n "${RENDER_GIT_REPO_SLUG:-}" ]] && sources+=("https://github.com/$RENDER_GIT_REPO_SLUG.git")
  for src in "${sources[@]}"; do
    git -C "$repo" fetch --quiet --unshallow "$src" >&2 || true
    [[ "$(git -C "$repo" rev-parse --is-shallow-repository)" == true ]] || break
  done
  if [[ "$(git -C "$repo" rev-parse --is-shallow-repository)" == true ]]; then
    echo "app-version: WARNING history is still shallow, the build number will be too low" >&2
  fi
fi

if ! stamp="$(TZ=UTC git -C "$repo" log -1 --format=%cd --date=format-local:%Y-%m HEAD 2>/dev/null)" || [[ -z "$stamp" ]]; then
  echo "$(date -u +%y).$((10#$(date -u +%m))).0"
  exit 0
fi
year="${stamp%-*}"
month="${stamp#*-}"
count="$(git -C "$repo" rev-list --count --since="$year-$month-01T00:00:00Z" HEAD 2>/dev/null || echo 0)"
echo "${year:2}.$((10#$month)).$count"

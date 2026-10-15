#!/usr/bin/env bash
# Prints the app version, YY.M.N (e.g. 26.10.7): the year and month of the latest
# commit, then the number of commits made that month. Every deploy follows a new
# commit, so the version goes up by itself; nothing to edit by hand, and the same
# commit always gives the same version.
set -euo pipefail
repo="$(cd "$(dirname "$0")/../../.." && pwd)"

# CI and Render clone shallowly, which would undercount.
if [[ "$(git -C "$repo" rev-parse --is-shallow-repository 2>/dev/null)" == true ]]; then
  git -C "$repo" fetch --quiet --unshallow 2>/dev/null || true
fi

if ! stamp="$(TZ=UTC git -C "$repo" log -1 --format=%cd --date=format-local:%Y-%m HEAD 2>/dev/null)" || [[ -z "$stamp" ]]; then
  echo "$(date -u +%y).$((10#$(date -u +%m))).0"
  exit 0
fi
year="${stamp%-*}"
month="${stamp#*-}"
count="$(git -C "$repo" rev-list --count --since="$year-$month-01T00:00:00Z" HEAD 2>/dev/null || echo 0)"
echo "${year:2}.$((10#$month)).$count"

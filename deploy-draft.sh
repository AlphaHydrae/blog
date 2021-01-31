#!/usr/bin/env bash
set -e

root="$( cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P )"

tmp_dir=`mktemp -d -t alphahydrae.draft.XXX`
#trap "local_cleanup $tmp_dir" EXIT

local_cleanup() {
  local tmp_dir="$1"
  test -n "$tmp_dir" && test -d "$tmp_dir" && rm -fr "$tmp_dir"
}

log() {
  set +x
  local msg="$@"
  echo "$msg"
  set -x
}

cd "$tmp_dir"

set -x

main_branch="$(git ls-remote --symref git@github.com:AlphaHydrae/blog-draft | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')"
echo "Main branch: $main_branch"

git init
git remote add origin git@github.com:AlphaHydrae/blog-draft.git
git fetch origin

for remote in `git branch -r`; do
  git branch --track "${remote#origin/}" "$remote"
done

cd "$root"
bundle exec jekyll build --config _config.yml,_config.draft.yml --destination "$tmp_dir" --drafts --future

cd "$tmp_dir"
git reset --soft "origin/$main_branch" --
git add --all .
git commit -m "Deploy static build on $(date)"
git push origin "$main_branch"

set +x

#!/usr/bin/env bash
set -e

root="$( cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P )"

tmp_dir=`mktemp -d -t alphahydrae.blog.XXX`
trap "local_cleanup $tmp_dir" EXIT

local_cleanup() {
  local tmp_dir="$1"
  test -n "$tmp_dir" && test -d "$tmp_dir" && rm -fr "$tmp_dir"
}

cd "$tmp_dir"

set -x

git init
git remote add origin git@github.com:AlphaHydrae/blog.git
git fetch origin gh-pages

for remote in `git branch -r`; do
  git branch --track "${remote#origin/}" "$remote"
done

cd "$root"
bundle exec jekyll build --config _config.yml --destination "$tmp_dir"

cd "$tmp_dir"
git reset --soft "origin/gh-pages" --
git add --all .
git commit -m "Deploy static build on $(date)"
git push origin HEAD:gh-pages

set +x

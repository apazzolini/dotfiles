#!/bin/bash

set -eo pipefail

branch_name=''

read_tracking_branch() {
  git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"
}

read_tracking_remote() {
  git for-each-ref --format='%(upstream:remotename)' "$(git symbolic-ref -q HEAD)"
}

fetch_branch_name() {
  branch_name=$(read_tracking_branch)
  if ! git rev-parse "$branch_name" > /dev/null 2>&1; then
    echo "\"$branch_name\" tracking branch does not exist"
    return 1
  fi
}

fetch_last_tag() {
  git tag -l | grep "review/$branch_name" | tail -1 || echo ""
}

fetch_default_branch() {
  for possible_default in develop master main; do
    possible_default_upstream="$(read_tracking_remote)/$possible_default"
    if git rev-parse "$possible_default_upstream" > /dev/null 2>&1; then
      echo "$possible_default_upstream"
      return
    fi
  done
  return 1
}

create_review_tag() {
  last_tag=$(fetch_last_tag)

  if [ -z "$last_tag" ]; then
    new_num="1"
  else
    if [ "$(git rev-parse "$last_tag")" = "$(git rev-parse "$branch_name")" ]; then
      echo "$last_tag is same as upstream"
      return
    fi
    last_num="${last_tag##*/}"
    new_num=$((last_num + 1))
  fi

  new_branch="review/$branch_name/$new_num"
  git tag "$new_branch" "$branch_name"
  echo "+ $new_branch"
}

list_review_tags() {
  git tag -l | grep "review/$branch_name" || echo "(none)"
}

diff_params=()
fetch_diff_params() {
  tags="$(list_review_tags)"
  if [ "$(echo "$tags" | wc -l)" -lt 2 ]; then
    echo "This command requires at least 2 tags"
    exit 1
  fi

  if [ "$#" -eq 3 ]; then
    first_tag="review/$branch_name/$2"
    second_tag="review/$branch_name/$3"
  elif [ "$#" -eq 2 ]; then
    first_tag="review/$branch_name/$2"
    second_tag="$(echo "$tags" | tail -1)" 
  else
    first_tag="$(echo "$tags" | tail -2 | head -1)" 
    second_tag="$(echo "$tags" | tail -1)" 
  fi
  diff_params=("$first_tag" "$second_tag")
  echo "${diff_params[0]} -> ${diff_params[1]}"
}

print_help() {
  echo "usage: review-tags.sh <command> [options]"
  echo "Available commands:"
  echo "    s|status - Prints the tracking branch"
  echo "    c|create - Create a tag on the on the tracking branch head"
  echo "    l|list - Lists tags"
  echo "    rd|range-diff [[from_tag] to_tag] - Compare two commit ranges with the base set to the default branch (develop|main|master) on the remote"
  echo "    d|diff [[from_tag] to_tag] - Show changes between commits"
  echo "    p|pull [branch] - Safely resets your local branch to upstream and creates a tag"
  echo "    g|goto [tag] - Safely resets your local branch to the given tag"
  echo "    prune - Delete all review tags which no longer have upstream branches"
  echo "    help - Prints this help documentation"
}

if [[ $# -lt 1 ]]; then
  print_help
  exit 1
fi

command="$1"
case $command in
  s|stat|status)
    read_tracking_branch
    ;;

  c|create)
    fetch_branch_name
    create_review_tag
    ;;

  l|list)
    fetch_branch_name
    list_review_tags
    ;;

  rd|range-diff)
    fetch_branch_name
    fetch_diff_params "$@"
    git range-diff "$(fetch_default_branch)" "${diff_params[0]}" "${diff_params[1]}"
    ;;

  d|diff)
    fetch_branch_name
    fetch_diff_params "$@"
    git diff "${diff_params[0]}" "${diff_params[1]}"
    ;;

  p|pull)
    git fetch
    if [ -n "$2" ]; then
      git checkout "$2"
    fi
    fetch_branch_name
    create_review_tag
    git reset --keep "$(read_tracking_branch)"
    ;;

  g|goto)
    fetch_branch_name
    if [ -z "$2" ]; then
      checkout_branch=$(fetch_last_tag)
    else
      checkout_branch="review/$branch_name/$2"
    fi
    echo "-> $checkout_branch"
    git reset --keep "$checkout_branch"
    ;;

  prune)
    for tag in $(git tag -l); do
      if [[ "$tag" =~ ^review/(.*)/[0-9]+$ ]]; then
        if ! git rev-parse "${BASH_REMATCH[1]}" > /dev/null 2>&1; then
          git tag -d "$tag"
        fi
      fi
    done
    ;;

  help|--help)
    print_help
    ;;

  *)
    echo "Unknown command $command"
    print_help
    exit 1
    ;;
esac

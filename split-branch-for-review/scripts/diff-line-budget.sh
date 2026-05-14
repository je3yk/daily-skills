#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-branch> [max-lines]" >&2
}

target="${1:-}"
max_lines="${2:-800}"

if [[ -z "$target" ]]; then
  usage
  exit 2
fi

if ! [[ "$max_lines" =~ ^[0-9]+$ ]]; then
  echo "max-lines must be a positive integer" >&2
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository" >&2
  exit 1
fi

if ! git rev-parse --verify "$target^{commit}" >/dev/null 2>&1; then
  echo "Target branch or ref not found: $target" >&2
  exit 1
fi

base="$(git merge-base HEAD "$target")"

git diff --numstat "$base..HEAD" |
  awk -F '\t' -v max="$max_lines" -v base="$base" -v target="$target" '
    function is_generated(path) {
      return path ~ /(^|\/)(node_modules|vendor|dist|build|coverage|target|Pods|DerivedData|\.next|\.nuxt|out|generated|gen|__generated__)(\/|$)/ ||
        path ~ /(^|\/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|Podfile\.lock|Cargo\.lock|go\.sum)$/ ||
        path ~ /(\.snap$|\.generated\.|\.gen\.|\.g\.|\.pb\.)/
    }

    function changed_lines(adds, dels) {
      if (adds == "-" || dels == "-") {
        return 0
      }
      return adds + dels
    }

    {
      path = $3
      lines = changed_lines($1, $2)

      if (is_generated(path)) {
        ignored += lines
        ignored_files += 1
      } else {
        counted += lines
        counted_files += 1
        files[path] = lines
      }
    }

    END {
      counted += 0
      ignored += 0
      counted_files += 0
      ignored_files += 0

      print "Target branch: " target
      print "Merge base: " base
      print "Counted changed lines: " counted
      print "Generated/ignored changed lines: " ignored
      print "Counted files: " counted_files
      print "Generated/ignored files: " ignored_files
      print "Budget: " max
      print "Status: " (counted <= max ? "within budget" : "over budget")
      print ""
      print "Counted files by changed lines:"
      for (path in files) {
        print files[path] "\t" path
      }
    }
  '

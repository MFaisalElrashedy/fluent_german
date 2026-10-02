#!/usr/bin/env bash
# Commit and push learning progress (data/, results/) when Claude stops.
# Cloud sessions are ephemeral, so progress must reach the remote to survive.
# Silent no-op when nothing changed. Never blocks the session.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

git add -- data results 2>/dev/null
git diff --cached --quiet -- data results && exit 0

git diff --cached --name-only -z -- data results \
  | xargs -0 git commit -q -m "Save learning progress ($(date -u +%Y-%m-%d))" -- || exit 0

branch="$(git rev-parse --abbrev-ref HEAD)"
for delay in 2 4 8 16; do
  git push -q -u origin "$branch" 2>/dev/null && {
    echo '{"systemMessage": "[Fluent] Progress committed and pushed"}'
    exit 0
  }
  sleep "$delay"
done
echo '{"systemMessage": "[Fluent] Progress committed locally, but push failed - ask Claude to push"}'
exit 0

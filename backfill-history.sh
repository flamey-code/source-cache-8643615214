#!/bin/bash
set -e

echo "=== ONE-TIME HISTORICAL BACKFILL ==="
echo "This will archive all changes from the past into history/ and archives/"
echo ""

mkdir -p history archives

# Get all commits in reverse order (oldest first)
COMMITS=$(git log --reverse --pretty=format:%H)

for commit in $COMMITS; do
  DATE=$(git show -s --format=%cd --date=short $commit)
  echo "Processing commit $commit ($DATE)..."
  
  HISTORY_DIR="history/$DATE"
  ARCHIVE_DIR="archives/$DATE"
  mkdir -p "$HISTORY_DIR" "$ARCHIVE_DIR"
  
  # Get files changed in this commit
  git show --name-only --pretty="" $commit | while read file; do
    if [ -f "$file" ]; then
      mkdir -p "$ARCHIVE_DIR/$(dirname "$file")"
      git show $commit:"$file" > "$ARCHIVE_DIR/$file" 2>/dev/null || true
      echo "$file" >> "$HISTORY_DIR/changes.md"
    fi
  done
done

echo ""
echo "✅ Historical backfill complete!"
echo "All past changes are now archived in history/ and archives/"

#!/bin/bash
set -e

DATE=$(date +%Y-%m-%d)
HISTORY_DIR="history/$DATE"
ARCHIVE_DIR="archives/$DATE"

mkdir -p "$HISTORY_DIR" "$ARCHIVE_DIR"

echo "# Daily Red Team Update - $DATE" > "$HISTORY_DIR/changes.md"
echo "" >> "$HISTORY_DIR/changes.md"

if [ ! -f HISTORY.md ]; then
  echo "# Red Team Everything Monorepo — Full Immutable History" > HISTORY.md
  echo "" >> HISTORY.md
  echo "This repo is strictly append-only. Nothing is ever deleted or edited in place." >> HISTORY.md
  echo "Every past version, variation, and upstream state is kept forever." >> HISTORY.md
  echo "" >> HISTORY.md
fi

echo "## $DATE" >> HISTORY.md
echo "" >> HISTORY.md

# Get list of all tracked files that changed since last commit
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || git ls-files)

for file in $CHANGED_FILES; do
  if [ -f "$file" ]; then
    echo "### $file" >> "$HISTORY_DIR/changes.md"
    echo "### $file" >> HISTORY.md
    
    # Archive the file
    mkdir -p "$ARCHIVE_DIR/$(dirname "$file")"
    cp "$file" "$ARCHIVE_DIR/$file" 2>/dev/null || true
    
    echo "- Archived to archives/$DATE/$file" >> "$HISTORY_DIR/changes.md"
    echo "- Archived to archives/$DATE/$file" >> HISTORY.md
  fi
done

# Also capture any new files in discovered-pocs
find discovered-pocs -type f -newer .git/index 2>/dev/null | while read newfile; do
  echo "### NEW: $newfile" >> "$HISTORY_DIR/changes.md"
  echo "### NEW: $newfile" >> HISTORY.md
  mkdir -p "$ARCHIVE_DIR/$(dirname "$newfile")"
  cp "$newfile" "$ARCHIVE_DIR/$newfile" 2>/dev/null || true
done

echo "" >> HISTORY.md
echo "✅ Daily snapshot complete - $DATE" >> HISTORY.md

echo "✅ History generated for $DATE"

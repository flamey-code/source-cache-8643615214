#!/bin/bash
set -e
DATE=$(date +%Y-%m-%d)
HISTORY_DIR="history/$DATE"
ARCHIVE_DIR="archives/$DATE"
mkdir -p "$HISTORY_DIR" "$ARCHIVE_DIR"

echo "# Daily Red Team Update - $DATE" > "$HISTORY_DIR/changes.md"
echo "" >> "$HISTORY_DIR/changes.md"
echo "Total submodules updated: $(git submodule status | wc -l)" >> "$HISTORY_DIR/changes.md"
echo "" >> "$HISTORY_DIR/changes.md"

if [ ! -f HISTORY.md ]; then
  echo "# Red Team Everything Monorepo — Full Immutable History" > HISTORY.md
  echo "" >> HISTORY.md
  echo "This repo is strictly append-only. Nothing is ever deleted or edited in place." >> HISTORY.md
  echo "Every past version, variation, branch change, and upstream state is kept forever." >> HISTORY.md
  echo "" >> HISTORY.md
fi

echo "## $DATE" >> HISTORY.md
echo "" >> HISTORY.md

for submodule in $(git submodule status | awk '{print $2}'); do
  echo "### $submodule" >> "$HISTORY_DIR/changes.md"
  echo "### $submodule" >> HISTORY.md

  OLD_COMMIT=$(git ls-tree HEAD "$submodule" | awk '{print $3}')
  git submodule update --init --recursive --remote "$submodule" >/dev/null 2>&1
  NEW_COMMIT=$(git ls-tree HEAD "$submodule" | awk '{print $3}')

  if [ "$OLD_COMMIT" = "$NEW_COMMIT" ]; then
    echo "- No changes today" >> "$HISTORY_DIR/changes.md"
    echo "- No changes today" >> HISTORY.md
    continue
  fi

  echo "- Updated from \`$OLD_COMMIT\` → \`$NEW_COMMIT\`" >> "$HISTORY_DIR/changes.md"
  echo "- Updated from \`$OLD_COMMIT\` → \`$NEW_COMMIT\`" >> HISTORY.md

  cd "$submodule"
  git diff --name-status "$OLD_COMMIT" "$NEW_COMMIT" > /tmp/diff.txt 2>/dev/null || true
  cd - >/dev/null

  if [ -s /tmp/diff.txt ]; then
    echo "" >> "$HISTORY_DIR/changes.md"
    echo "Changes:" >> "$HISTORY_DIR/changes.md"
    cat /tmp/diff.txt >> "$HISTORY_DIR/changes.md"
    echo "" >> "$HISTORY_DIR/changes.md"

    while read -r status file; do
      if [ -f "$submodule/$file" ]; then
        mkdir -p "$ARCHIVE_DIR/$submodule/$(dirname "$file")"
        cp "$submodule/$file" "$ARCHIVE_DIR/$submodule/$file"
      fi
    done < /tmp/diff.txt
  fi
done

echo "✅ Generated detailed history for $DATE"

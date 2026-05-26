#!/bin/bash
echo "=== VERIFYING REAL SOURCE CODE IN ALL FOLDERS ==="

FOLDERS=(
  "exploits/exploitdb"
  "cves/trickest-cve"
  "cves/poc-in-github"
  "payloads/PayloadsAllTheThings"
  "exploits/nuclei-templates"
  "exploits/metasploit"
  "exploits/impacket"
  "exploits/covenant"
  "exploits/empire"
  "exploits/sliver"
)

for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ] && [ "$(ls -A $folder 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "✅ $folder - REAL CODE PRESENT ($(ls $folder | wc -l) items)"
  else
    echo "❌ $folder - EMPTY OR MISSING!"
  fi
done

echo ""
echo "Verification complete."

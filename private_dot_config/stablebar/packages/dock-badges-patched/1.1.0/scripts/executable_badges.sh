#!/bin/bash
set -euo pipefail

while IFS= read -r app; do
  info=$(lsappinfo info -only bundleID -only bundlepath "$app" 2>/dev/null || true)
  bundle=$(printf '%s\n' "$info" | sed -n 's/^ *bundleID="\([^"]*\)".*/\1/p')
  [[ -n $bundle ]] || continue
  path=$(printf '%s\n' "$info" | sed -n 's/^ *bundle path="\([^"]*\)".*/\1/p')
  # macOS 27의 lsappinfo는 StatusLabel을 반환하지 않아 Dock 접근성 값으로 읽는다.
  badge=$(osascript -e 'on run argv
tell application "System Events" to tell process "Dock" to get value of attribute "AXStatusLabel" of UI element (item 1 of argv) of list 1
end run' "$app" 2>/dev/null || true)
  [[ $badge == "missing value" ]] && badge=""
  jq -cn --arg app "$app" --arg bundle "$bundle" --arg path "$path" --arg badge "$badge" '{app: $app, bundle: $bundle, path: $path, badge: $badge}'
done < <(printf '%s' "$APPS" | jq -Rrs 'split(",")[] | gsub("^ +| +$"; "") | select(length > 0)') |
  jq -s '
    map(. + {count: (if .badge | test("^[0-9]+$") then .badge | tonumber else 0 end)}) as $apps |
    ([$apps[].count] | add // 0 | tostring) as $total |
    {
      text: $total,
      icon: "app.badge",
      fields: {total: $total, hint: (if $apps | length == 0 then "No watched apps are running." else "Total counts numeric badges." end)},
      lists: {apps: [$apps[] | {app, bundle, path, badge: (if .badge == "" then "0" else .badge end)}]}
    }'

#!/bin/bash
set -euo pipefail

# 설정 항목에 최소·최대 필드가 없어서 config.json은 3초마다 실행하고, 실제 갱신 주기는 여기서 3~30초로 제한한다.
interval=${INTERVAL:-10}
interval=${interval%%.*}
[[ $interval == -* ]] && interval=3
[[ $interval =~ ^[0-9]+$ ]] || interval=10
interval=$((10#$interval))
((interval < 3)) && interval=3
((interval > 30)) && interval=30

cache="${TMPDIR:-/tmp}/stablebar-dock-badges-patched.json"
if [[ -f $cache && -f $cache.apps && $(<"$cache.apps") == "$APPS" ]]; then
  # 실행 시각이 3초 단위라 1초 여유를 두지 않으면 10초 설정이 12초 주기로 밀린다.
  if (($(date +%s) - $(stat -f %m "$cache") < interval - 1)); then
    cat "$cache"
    exit 0
  fi
fi

while IFS= read -r app; do
  info=$(lsappinfo info -long "$app")
  bundle=$(printf '%s\n' "$info" | sed -n 's/^"CFBundleIdentifier"="\([^"]*\)"$/\1/p')
  [[ -n $bundle ]] || continue
  path=$(printf '%s\n' "$info" | sed -n 's/^"LSBundlePath"="\([^"]*\)"$/\1/p')
  badge=$(printf '%s\n' "$info" | sed -n 's/.*"label"="\([^"]*\)".*/\1/p')
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
    }' >"$cache.$$"

mv "$cache.$$" "$cache"
printf '%s' "$APPS" >"$cache.apps"
cat "$cache"

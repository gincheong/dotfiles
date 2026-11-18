#!/bin/bash
# 로컬 파일의 변경을 chezmoi 템플릿(.tmpl) 소스에 반영한다.
# chezmoi re-add는 템플릿 소스를 수정하지 않는다.
#
# 사용법: chezmoi-tmpl-re-add [-n] [대상 경로 ...]
#   -n  템플릿을 수정하지 않고 결과만 출력한다
# 대상 경로를 생략하면 chezmoi status에서 로컬과 소스가 다른 파일을 전부 확인한다.

set -euo pipefail

dry_run=false
if [ "${1:-}" = "-n" ] || [ "${1:-}" = "--dry-run" ]; then
  dry_run=true
  shift
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
source_dir=$(chezmoi source-path)
failed=0

hunks() { grep -c '^@@' "$1" || true; }
show() { tail -n +3 "$1" | sed 's/^/    /'; }

process() {
  local target=$1 source=$2
  echo "${source#"$source_dir"/}"

  # 제어 블록이나 여러 줄 표현식이 있으면 렌더 결과와 템플릿의 줄 번호가 달라진다
  chezmoi cat "$target" > "$tmp/rendered"
  if grep -Eq '\{\{-?[[:space:]]*(if|range|with|define|block)[[:space:]]' "$source" ||
    [ "$(wc -l < "$source")" -ne "$(wc -l < "$tmp/rendered")" ]; then
    echo "  보류: 템플릿과 렌더 결과의 줄이 1:1로 대응하지 않아 직접 수정해야 한다"
    return
  fi

  diff -U0 "$tmp/rendered" "$target" > "$tmp/patch" || true
  if [ ! -s "$tmp/patch" ]; then
    echo "  차이 없음"
    return
  fi

  # 표현식이 있는 줄의 hunk는 템플릿 내용과 맞지 않아 reject된다
  cp "$source" "$tmp/new"
  patch -s -r "$tmp/rej" "$tmp/new" < "$tmp/patch" > /dev/null 2>&1 || true

  if ! chezmoi execute-template < "$tmp/new" > "$tmp/rerendered" 2> "$tmp/err"; then
    echo "  실패: 수정한 템플릿을 렌더할 수 없다. 파일은 수정하지 않았다." >&2
    sed 's/^/    /' "$tmp/err" >&2
    failed=1
    return
  fi
  diff -U0 "$source" "$tmp/new" > "$tmp/applied" || true
  diff -U0 "$tmp/rerendered" "$target" > "$tmp/held" || true
  local applied held
  applied=$(hunks "$tmp/applied")
  held=$(hunks "$tmp/held")

  # hunk가 다른 위치에 적용됐으면 남은 차이의 개수가 맞지 않는다
  if [ $((applied + held)) -ne "$(hunks "$tmp/patch")" ]; then
    echo "  실패: 수정한 템플릿의 렌더 결과가 예상과 다르다. 파일은 수정하지 않았다." >&2
    failed=1
    return
  fi

  if [ "$applied" -gt 0 ]; then
    echo "  반영 ${applied}건 (- 기존 템플릿, + 로컬)"
    show "$tmp/applied"
  fi
  if [ "$held" -gt 0 ]; then
    echo "  보류 ${held}건, 템플릿 표현식에 걸림 (- 렌더 결과, + 로컬)"
    show "$tmp/held"
  fi
  if [ "$applied" -eq 0 ]; then
    return
  fi
  if $dry_run; then
    echo "  dry-run: 템플릿을 수정하지 않았다"
  else
    cat "$tmp/new" > "$source"
  fi
}

check() {
  local target=$1 source name
  source=$(chezmoi source-path "$target")
  name=$(basename "$source")
  case "$name" in
    *encrypted_* | modify_*) echo "건너뜀 (암호화 또는 modify 스크립트): $target" ;;
    *.tmpl)
      if [ -f "$target" ]; then
        process "$target" "$source"
      else
        echo "건너뜀 (로컬 파일 없음): $target"
      fi
      ;;
    *) echo "템플릿 아님, chezmoi re-add 대상: $target" ;;
  esac
}

if [ $# -gt 0 ]; then
  for target in "$@"; do
    check "$target"
  done
else
  dest=$(chezmoi target-path)
  while IFS= read -r line; do
    if [ "${line:1:1}" = "M" ]; then
      check "$dest/${line:3}"
    else
      echo "건너뜀 (status ${line:0:2}): $dest/${line:3}"
    fi
  done < <(chezmoi status)
fi

exit "$failed"

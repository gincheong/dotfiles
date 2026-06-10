# ~/.shell-utils.zsh
# 클립보드 복사 유틸 및 디렉토리 이동 alias 모음

# .zshrc에서 다음과 같이 source 하여 사용
# [ -f "$HOME/.shell-utils.zsh" ] && source "$HOME/.shell-utils.zsh"

alias groot='cd "$(git rev-parse --show-toplevel)"'

alias cddown='cd ~/Downloads'

alias cppwd='pwd | {read var; echo $var | pbcopy; echo "클립보드 복사: $var"; }'
alias cpbr='printf "$(git branch --show-current)" | { read br; printf "$br" | pbcopy; echo "클립보드 복사: $br"; }'

cpci() {
  # 인자가 없으면 기본값 1 사용
  local index=${1:-1}
  # n번째 커밋을 가져오기 위해 (index - 1) 만큼 skip
  local skip_count=$((index - 1))

  local msg=$(git log --skip=$skip_count -1 --pretty=%s)

  if [ -n "$msg" ]; then
    printf "$msg" | pbcopy
    echo "클립보드 복사: $msg"
  else
    echo "커밋이 존재하지 않습니다."
  fi
}

cphash() {
  # 인자가 없으면 기본값으로 1(최신 커밋) 사용
  local count=${1:-1}

  # n번째 전 커밋의 해시와 메시지를 가져옴 (HEAD~0, HEAD~1...)
  local target="HEAD~$((count - 1))"
  local commit_info=$(git log -1 --format="%H|%s" "$target" 2>/dev/null)

  if [ -z "$commit_info" ]; then
    echo "❌ 에러: 해당 위치에 커밋이 존재하지 않습니다."
    return 1
  fi

  # 해시와 메시지 분리
  local hash=$(echo "$commit_info" | cut -d'|' -f1)
  local message=$(echo "$commit_info" | cut -d'|' -f2)

  # 클립보드 복사 및 출력
  echo -n "$hash" | pbcopy
  echo "대상 커밋: $message"
  echo "클립보드 복사: $hash"
}

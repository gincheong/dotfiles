# claude-sessions: 최근 Claude Code 세션을 워크트리 경로 + 세션이름 + 첫 질문과 함께 보여준다.
#   claude-sessions          최근 15개
#   claude-sessions 30       최근 30개
#   claude-sessions -g 키워드 세션 내용에서 키워드 검색 (어느 워크트리인지 + resume 명령 출력)
claude-sessions() {
  local proj="$HOME/.claude/projects"
  # 색상 (타임스탬프=cyan, 경로=yellow, 브랜치=magenta, 세션이름=bold, 첫질문=dim)
  local C_TS=$'\033[36m' C_PATH=$'\033[33m' C_BR=$'\033[35m' C_TITLE=$'\033[1m' C_MSG=$'\033[97m' C_CMD=$'\033[2m' C_R=$'\033[0m'

  if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
    print -P "%F{cyan}claude-sessions%f — 최근 Claude Code 세션을 워크트리 경로·세션이름·브랜치와 함께 조회"
    echo ""
    print -P "%BUSAGE%b"
    print -P "  %F{green}claude-sessions%f [N]            최근 N개 세션 (기본 15)"
    print -P "  %F{green}claude-sessions%f -g <키워드>     세션 내용으로 검색"
    print -P "  %F{green}claude-sessions%f -h|--help|help  이 도움말"
    echo ""
    print -P "%B출력 형식%b"
    print -P "  %F{cyan}[날짜 시각]%f %F{yellow}워크트리경로%f %F{magenta}(브랜치)%f %B🏷 세션이름%b"
    print -P "      └ %F{8}첫 질문%f"
    print -P "      ↳ %F{green}cd ... && claude --resume <id>%f   (복붙용 resume 명령)"
    echo ""
    print -P "%B예시%b"
    print -P "  %F{green}claude-sessions 30%f         최근 30개 훑어보기"
    print -P "  %F{green}claude-sessions -g PROD%f    'PROD' 들어간 세션 찾아 resume 명령 받기"
    print -P "  %F{8}# -g 결과의 'cd ... && claude --resume ...' 줄을 복붙하면 그 워크트리로 복원%f"
    return 0
  fi

  # 한 세션 파일에서 cwd / gitBranch / 첫 user 질문 추출 (python)
  _cs_meta() {
    grep -m1 '"type":"user"' "$1" | python3 -c "import sys,json
try:
  d=json.loads(sys.stdin.readline())
  c=d.get('message',{}).get('content','')
  if isinstance(c,list): c=' '.join(x.get('text','') for x in c if isinstance(x,dict))
  print(d.get('cwd',''))
  print(d.get('gitBranch',''))
  print(str(c).replace(chr(10),' ')[:70])
except: print('\n\n')" 2>/dev/null
  }
  # 마지막 custom-title (세션 이름)
  _cs_title() {
    grep '"type":"custom-title"' "$1" 2>/dev/null | tail -1 \
      | grep -o '"customTitle":"[^"]*"' | sed 's/"customTitle":"//;s/"//'
  }

  local f cwd br msg ts title sid meta
  local files
  if [[ "$1" == "-g" ]]; then
    [[ -z "$2" ]] && { echo "usage: claude-sessions -g <keyword>"; return 1; }
    files=$(grep -rl "$2" "$proj"/*/*.jsonl 2>/dev/null)
  else
    files=$(ls -t "$proj"/*/*.jsonl 2>/dev/null | head -"${1:-15}")
  fi

  echo "$files" | while read -r f; do
    [[ -z "$f" ]] && continue
    meta=$(_cs_meta "$f")
    cwd=$(echo "$meta" | sed -n '1p')
    br=$(echo "$meta"  | sed -n '2p')
    msg=$(echo "$meta" | sed -n '3p')
    title=$(_cs_title "$f")
    sid="${f:t:r}"
    ts=$(stat -f '%Sm' -t '%m-%d %H:%M' "$f")
    echo "${C_TS}[$ts]${C_R} ${C_PATH}${cwd}${C_R}${br:+ ${C_BR}(${br})${C_R}}${title:+ ${C_TITLE}🏷 ${title}${C_R}}"
    echo "    └ ${C_MSG}${msg}${C_R}"
    echo "    ↳ ${C_CMD}cd \"$cwd\" && claude --resume $sid${C_R}"
  done

  unfunction _cs_meta _cs_title
}

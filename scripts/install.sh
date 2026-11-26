#!/bin/sh
# AI-DLC workflow (규칙, 스킬, Claude Code hook) 를 대상 프로젝트에 설치
# 사용: ./scripts/install.sh [-a claude|codex|both] [-f] [프로젝트 경로]
#   -a  설치 대상 에이전트 (기본 claude)
#   -f  이미 있는 파일도 덮어쓰기
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
AGENT=claude
FORCE=0
while getopts "a:f" opt; do
  case $opt in
    a) AGENT=$OPTARG ;;
    f) FORCE=1 ;;
    *) echo "사용: $0 [-a claude|codex|both] [-f] [프로젝트 경로]"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
PROJECT=${1:-$(pwd)}
case $AGENT in claude|codex|both) ;; *) echo "-a 는 claude, codex, both 중 하나"; exit 1 ;; esac
[ -d "$PROJECT" ] || { echo "프로젝트 폴더 없음: $PROJECT"; exit 1; }
PROJECT=$(cd "$PROJECT" && pwd)

copy_safe() {  # $1 원본, $2 대상
  if [ -e "$2" ] && [ $FORCE -eq 0 ]; then
    echo "  건너뜀 (이미 있음, 덮어쓰려면 -f): $2"; return
  fi
  rm -rf "$2"
  mkdir -p "$(dirname "$2")"
  cp -R "$1" "$2"
  echo "  설치: $2"
}

add_snippet() {  # $1 대상 파일, $2 템플릿
  if [ -f "$1" ] && grep -q "aidlc-workflow:begin" "$1"; then
    echo "  건너뜀 (AI-DLC 절 이미 있음): $1"; return
  fi
  [ -s "$1" ] && printf '\n' >> "$1"
  cat "$2" >> "$1"
  echo "  AI-DLC 절 추가: $1"
}

install_skills() {  # $1 skills 폴더
  for d in "$ROOT"/skills/*/; do
    copy_safe "${d%/}" "$1/$(basename "$d")"
  done
}

echo "[1] 규칙 -> $PROJECT/.aidlc-rule-details"
copy_safe "$ROOT/aidlc-rule-details" "$PROJECT/.aidlc-rule-details"

if [ "$AGENT" = claude ] || [ "$AGENT" = both ]; then
  echo "[2] Claude Code"
  C="$PROJECT/.claude"
  install_skills "$C/skills"
  copy_safe "$ROOT/claude/agents/aidlc-traceability.md" "$C/agents/aidlc-traceability.md"
  for f in "$ROOT"/claude/hooks/*.py; do copy_safe "$f" "$C/hooks/$(basename "$f")"; done
  if [ -f "$C/settings.json" ] && grep -q "aidlc_audit.py" "$C/settings.json"; then
    echo "  건너뜀 (AI-DLC hook 이미 등록됨): $C/settings.json"
  elif [ -f "$C/settings.json" ]; then
    cp "$ROOT/claude/settings.json" "$C/settings.aidlc.json"
    echo "  주의: settings.json 이 이미 있어 덮어쓰지 않음. .claude/settings.aidlc.json 의 hooks, statusLine 을 직접 합칠 것"
  else
    cp "$ROOT/claude/settings.json" "$C/settings.json"
    echo "  설치: $C/settings.json"
  fi
  add_snippet "$PROJECT/CLAUDE.md" "$ROOT/templates/CLAUDE.aidlc.md"
fi

if [ "$AGENT" = codex ] || [ "$AGENT" = both ]; then
  echo "[3] Codex"
  install_skills "$PROJECT/.agents/skills"
  add_snippet "$PROJECT/AGENTS.md" "$ROOT/templates/AGENTS.aidlc.md"
fi

echo "완료. 에이전트를 다시 시작한 뒤 /aidlc (Claude Code) 또는 \$aidlc (Codex) 로 상태를 확인하세요."

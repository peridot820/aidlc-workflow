# aidlc-workflow

AI-DLC (AI-Driven Development Life Cycle) 를 어느 프로젝트에서나 쓸 수 있게 묶은 규칙, 스킬, Claude Code hook 모음입니다. AI 코딩 에이전트 (Claude Code, Codex) 가 요구사항 분석부터 설계, 코드 생성, 빌드/테스트, 운영까지 stage 별로 질문하고, 산출물을 남기고, 사람의 승인을 받으며 진행하게 합니다.

- 규칙 버전: `1.0.1-ko+dx` (`aidlc-rule-details/VERSION`)
- 원본: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) 1.0 규칙의 한국어판 + 개발 경험 (dx) 확장 (NOTICE.md 참조)

## 구성

```
aidlc-rule-details/    workflow 규칙 (설치 시 <프로젝트>/.aidlc-rule-details/)
  core-workflow.md       전체 흐름과 공통 진행 규칙 (진입점)
  common/                질문 형식, 내용 검증, 세션 재개, stage 점검표 등
  inception/ construction/ operations/   stage 별 상세 규칙
  extensions/            보안, 복원력, 속성 기반 테스트 확장 (opt-in)
skills/                스킬 23개 (Claude Code: .claude/skills/, Codex: .agents/skills/)
claude/                Claude Code 전용 부속 (설치 시 <프로젝트>/.claude/)
  hooks/                 입력 자동 기록, 세션 재개 안내, 상태 표시줄
  agents/                추적 점검 서브에이전트
  settings.json          hook, statusLine 등록
templates/             CLAUDE.md, AGENTS.md 에 덧붙일 AI-DLC 절
scripts/               설치 스크립트 (install.ps1, install.sh)
docs/                  스킬 목록, 사용 지침과 호출 순서
```

## 설치

필요 조건: 대상 프로젝트 폴더, Claude Code hook 을 쓰려면 Python 3 (`python` 명령)

### 설치 스크립트 (권장)

```powershell
# Windows (PowerShell)
git clone https://github.com/peridot820/aidlc-workflow.git
.\aidlc-workflow\scripts\install.ps1 -Project C:\work\my-app -Agent claude   # claude | codex | both
```

```sh
# macOS, Linux, Git Bash
git clone https://github.com/peridot820/aidlc-workflow.git
./aidlc-workflow/scripts/install.sh -a claude /path/to/my-app                 # -a claude | codex | both
```

- 이미 있는 파일은 건너뛴다. 덮어쓰려면 `-Force` (PowerShell) 또는 `-f` (sh)
- `CLAUDE.md`, `AGENTS.md` 는 덮어쓰지 않고 끝에 AI-DLC 절 (`aidlc-workflow:begin` ~ `end` 표시) 을 한 번만 덧붙인다
- 대상 프로젝트에 `.claude/settings.json` 이 이미 있으면 `.claude/settings.aidlc.json` 으로 따로 두므로, 그 안의 `hooks`, `statusLine` 을 직접 합친다
- 설치 후 에이전트를 다시 시작한다

### Claude Code 수동 설치

| 원본 | 대상 프로젝트 위치 |
| --- | --- |
| `aidlc-rule-details/` | `.aidlc-rule-details/` |
| `skills/*` | `.claude/skills/*` |
| `claude/hooks/*.py` | `.claude/hooks/` |
| `claude/agents/aidlc-traceability.md` | `.claude/agents/` |
| `claude/settings.json` | `.claude/settings.json` (기존 파일이 있으면 `hooks`, `statusLine` 만 합치기) |
| `templates/CLAUDE.aidlc.md` | `CLAUDE.md` 끝에 붙이기 |

- macOS, Linux 에서 `python` 명령이 없으면 `.claude/settings.json` 의 `python` 을 `python3` 로 바꾼다
- 스킬만 모든 프로젝트에서 쓰려면 `skills/*` 를 `~/.claude/skills/` 에 둘 수 있다. 단 규칙 (`.aidlc-rule-details/`) 과 hook 은 프로젝트마다 필요하다

### Codex 수동 설치

| 원본 | 대상 프로젝트 위치 |
| --- | --- |
| `aidlc-rule-details/` | `.aidlc-rule-details/` |
| `skills/*` | `.agents/skills/*` (Codex 는 실행 폴더에서 저장소 루트까지의 `.agents/skills` 를 읽음) |
| `templates/AGENTS.aidlc.md` | `AGENTS.md` 끝에 붙이기 |

- 사용자 공통으로 쓰려면 스킬을 `~/.agents/skills/` 에 둔다 (규칙은 프로젝트마다 필요)
- 스킬이 보이지 않으면 Codex 를 다시 시작한다. `/skills` 로 목록을 확인한다
- `claude/` 폴더 (hook, statusLine, 서브에이전트) 는 Claude Code 전용이라 Codex 에는 설치하지 않는다

### 설치 확인

| 확인 | Claude Code | Codex |
| --- | --- | --- |
| 스킬 인식 | `/aidlc` 입력 시 "AI-DLC 시작 전" 안내 | `$aidlc` 입력 시 같은 안내 |
| 규칙 연결 | `CLAUDE.md` 에 `@.aidlc-rule-details/core-workflow.md` 줄 | `AGENTS.md` 에 AI-DLC 절 |
| hook | 아무 입력 후 `aidlc-docs/audit.md` 에 "사용자 입력 (hook 자동 기록)" 항목 생김 (aidlc-docs 가 있거나 입력에 AI-DLC 가 들어 있을 때) | 해당 없음 |

## 스킬 목록 (요약)

| 구분 | 스킬 | 호출 예 (Claude Code / Codex) |
| --- | --- | --- |
| 상태, 진입 | `aidlc` | `/aidlc`, `/aidlc req` / `$aidlc` |
| INCEPTION | `aidlc-inception-workspace-detection`, `-reverse-engineering`, `-requirements-analysis`, `-user-stories`, `-workflow-planning`, `-application-design`, `-units-generation` | `/aidlc-inception-workspace-detection` |
| CONSTRUCTION | `aidlc-construction-functional-design`, `-nfr-requirements`, `-nfr-design`, `-infrastructure-design`, `-code-generation`, `-build-and-test` | `/aidlc-construction-code-generation <unit>` |
| OPERATIONS | `aidlc-operations-deployment-pipeline`, `-environment-provisioning`, `-deployment-execution`, `-observability-setup`, `-incident-response`, `-performance-validation`, `-feedback-optimization` | `/aidlc-operations-deployment-pipeline` |
| 추적 점검 | `traceability-check`, `traceability-check-agent` (Claude Code 전용) | `/traceability-check inception` |

- 별칭, 실행 조건, 인자, 최소/권장 구성: [docs/skills.md](docs/skills.md)

## 호출 순서 (요약)

1. `/aidlc` 로 상태 확인
2. `/aidlc-inception-workspace-detection` 으로 시작 (또는 "Using AI-DLC, ..." 자연어 요청)
3. 각 stage 완료 메시지에서 "승인 후 계속" 을 고르면 실행 계획 순서대로 다음 stage 진행: Reverse Engineering (기존 코드) -> Requirements Analysis -> User Stories -> Workflow Planning -> (Application Design, Units Generation)
4. INCEPTION 끝에 `/traceability-check inception`
5. unit 마다 Functional Design 등 설계 stage -> Code Generation (계획 승인 -> 생성)
6. Build and Test 후 `/traceability-check construction`
7. 배포 대상이 있으면 Operations stage, 없으면 workflow 완료

- 상황별 호출 (특정 stage 이동, `--single`, 재개), 질문 파일 답하는 법, 산출물 위치: [docs/workflow-guide.md](docs/workflow-guide.md)

## 규칙 수정

- stage 를 추가하거나 순서를 바꾸면 `skills/aidlc/stage-map.md` 와 해당 stage 스킬의 `SKILL.md` 표를 함께 고친다
- `core-workflow.md` 를 고치면 `aidlc-rule-details/core-workflow.sha256` 도 다시 계산한다 (`sha256sum core-workflow.md`)

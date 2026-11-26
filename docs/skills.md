# 스킬 목록

- 설치 위치: Claude Code = `<프로젝트>/.claude/skills/`, Codex = `<프로젝트>/.agents/skills/`
- 호출: Claude Code = `/스킬이름 인자`, Codex = `$스킬이름 인자` (또는 `/skills` 에서 선택)
- 스킬 본문의 `/aidlc-...` 표기는 Claude Code 기준이다. Codex 에서는 `$aidlc-...` 로 바꿔 부른다
- stage 스킬은 "어디서 시작할지" 만 정한다. 실제 진행 방식은 항상 `.aidlc-rule-details/` 의 규칙 파일을 따른다

## 1. 진입, 상태 스킬

| 스킬 | 인자 | 하는 일 | 필수 |
| --- | --- | --- | --- |
| `aidlc` | 없음, `status`, `<별칭> [unit] [--single]` | 진행 상태 표 (현재/다음 stage, phase 별 완료 수) 와 다음에 부를 스킬 안내. 별칭을 주면 그 stage 스킬과 같은 동작 | 필수 |

- `aidlc/stage-map.md`: stage 순서, 별칭, 상태 표기, 실행 조건 표 (모든 stage 스킬이 참조)
- `aidlc/stage-runner.md`: stage 스킬 공통 절차 (이동, 단독 실행, 앞 산출물 확인, audit 형식)
- 이 두 파일은 `aidlc` 스킬 폴더에 있으므로 stage 스킬만 따로 설치하면 동작하지 않는다

## 2. stage 스킬 (20개)

### INCEPTION

| # | 스킬 | 별칭 | 실행 조건 | unit 인자 |
| --- | --- | --- | --- | --- |
| 1 | `aidlc-inception-workspace-detection` | `wd` | ALWAYS | - |
| 2 | `aidlc-inception-reverse-engineering` | `re` | CONDITIONAL (기존 코드가 있을 때) | - |
| 3 | `aidlc-inception-requirements-analysis` | `req` | ALWAYS (깊이 조정) | - |
| 4 | `aidlc-inception-user-stories` | `stories` | CONDITIONAL | - |
| 5 | `aidlc-inception-workflow-planning` | `plan` | ALWAYS | - |
| 6 | `aidlc-inception-application-design` | `design` | CONDITIONAL | - |
| 7 | `aidlc-inception-units-generation` | `units` | CONDITIONAL | - |

### CONSTRUCTION (8 ~ 12 는 unit 마다 반복)

| # | 스킬 | 별칭 | 실행 조건 | unit 인자 |
| --- | --- | --- | --- | --- |
| 8 | `aidlc-construction-functional-design` | `fd` | CONDITIONAL | 필요 |
| 9 | `aidlc-construction-nfr-requirements` | `nfr-req` | CONDITIONAL | 필요 |
| 10 | `aidlc-construction-nfr-design` | `nfr` | CONDITIONAL | 필요 |
| 11 | `aidlc-construction-infrastructure-design` | `infra` | CONDITIONAL | 필요 |
| 12 | `aidlc-construction-code-generation` | `codegen` | ALWAYS | 필요 |
| 13 | `aidlc-construction-build-and-test` | `bt` | ALWAYS | - (전체 unit 대상) |

### OPERATIONS (phase 단위 1회, 모두 조건부)

| # | 스킬 | 별칭 | 실행 조건 |
| --- | --- | --- | --- |
| 14 | `aidlc-operations-deployment-pipeline` | `pipeline` | 배포 대상이 확인될 때 |
| 15 | `aidlc-operations-environment-provisioning` | `env` | 새 환경이나 환경 검증이 필요할 때 |
| 16 | `aidlc-operations-deployment-execution` | `deploy` | 배포 대상, 환경, 방식이 확인될 때 |
| 17 | `aidlc-operations-observability-setup` | `obs` | SLO, 지표, 알람 정의가 필요할 때 |
| 18 | `aidlc-operations-incident-response` | `incident` | 장애 대응 절차가 필요할 때 |
| 19 | `aidlc-operations-performance-validation` | `perf` | 성능 NFR 을 실환경에서 검증할 때 |
| 20 | `aidlc-operations-feedback-optimization` | `feedback` | 운영 데이터가 있을 때 |

- 인자 없음 = "이동": workflow 진행 위치를 그 stage 로 옮기고 실행 (건너뛴 stage 는 SKIP, 지난 stage 는 재오픈으로 표기)
- `--single` = 그 stage 만 실행하고 진행 위치는 그대로 (`aidlc-state.md` 의 `## Single-Stage Runs` 에 1줄 기록)
- unit 이 필요한 stage 에 unit 을 빼면 `unit-of-work.md` 의 unit 목록을 보여 주고 고르게 한다

## 3. 점검 스킬 (stage 아님)

| 스킬 | 인자 | 하는 일 | 필수 |
| --- | --- | --- | --- |
| `traceability-check` | `inception`, `construction`, 없음 (상태로 추정) | 요구 -> 스토리 -> 컴포넌트 -> Unit (-> 구현 계획 -> 소스, 테스트 -> 실행 결과) 연결을 양방향 대조해 GAP, ORPHAN 을 찾고 `aidlc-docs/verification/phase-check-*.md` 에 결과를 남김 | 권장 |
| `traceability-check-agent` | 위와 같음 | 같은 점검을 서브에이전트 `aidlc-traceability` 에 맡기고 메인은 요약과 승인만 처리 | 선택 (Claude Code 전용) |

- `traceability-check/result-template.md`: 결과 파일 양식
- `traceability-check-agent` 는 `.claude/agents/aidlc-traceability.md` 서브에이전트가 있어야 한다. Codex 에서는 `traceability-check` 를 쓴다

## 4. Claude Code 전용 부속 (스킬 아님)

| 파일 | 종류 | 하는 일 |
| --- | --- | --- |
| `.claude/hooks/aidlc_audit.py` | UserPromptSubmit hook | 사용자 입력 원문을 `aidlc-docs/audit.md` 에 자동 기록하고, 기록 시각을 대화에 알려 줌 (AI 가 원문을 다시 적지 않게) |
| `.claude/hooks/aidlc_session.py` | SessionStart hook | 세션 시작, 재개, 압축 때 현재/다음 stage, 마지막 audit 항목, 답변 대기 질문 파일을 대화에 주입 |
| `.claude/hooks/aidlc_statusline.py` | statusLine | 화면 아래 1줄에 phase, 현재 stage (unit), 완료 수/전체 수, 다음 stage 표시 |
| `.claude/hooks/aidlc_common.py` | 공통 모듈 | 위 3개가 쓰는 상태 파일 해석 (표준 라이브러리만 사용) |
| `.claude/agents/aidlc-traceability.md` | 서브에이전트 | `traceability-check-agent` 가 호출하는 독립 점검자 |
| `.claude/settings.json` | 설정 | 위 hook 과 statusLine 등록 |

## 5. 최소 구성과 권장 구성

| 구성 | 포함 | 용도 |
| --- | --- | --- |
| 최소 | `.aidlc-rule-details/` + `CLAUDE.md` 또는 `AGENTS.md` 의 AI-DLC 절 | 자연어 "Using AI-DLC, ..." 로만 진행 (스킬 없이도 workflow 동작) |
| 권장 | 최소 + `aidlc` + stage 스킬 20개 + `traceability-check` | 상태 확인, stage 지정 이동, 단독 실행, phase 경계 추적 점검 |
| Claude Code 전체 | 권장 + hook 3개 + statusLine + `traceability-check-agent` + 서브에이전트 | 입력 자동 기록, 세션 재개 안내, 진행 위치 상시 표시 |

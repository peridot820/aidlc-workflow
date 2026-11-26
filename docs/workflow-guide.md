# 사용 지침과 스킬 호출 순서

- 아래 예시는 Claude Code 표기 (`/스킬`) 다. Codex 는 `/` 대신 `$` 를 쓴다 (예: `/aidlc` -> `$aidlc`)

## 1. 시작하는 두 가지 방법

| 방법 | 입력 예 | 동작 |
| --- | --- | --- |
| 자연어 | `Using AI-DLC, 보호자 공유 API 를 docs/prd.md 기준으로 만들어 줘` | core-workflow 규칙대로 Workspace Detection 부터 순서대로 진행 |
| 스킬 | `/aidlc-inception-workspace-detection` | 첫 stage 를 명시적으로 시작. 이후 각 stage 의 승인 메뉴로 다음 stage 진행 |

- 어느 쪽이든 결과물은 같다: `aidlc-docs/aidlc-state.md` (진행 상태), `aidlc-docs/audit.md` (입력, 응답, 승인 기록), stage 별 산출물
- 언제든 `/aidlc` 로 현재 위치와 다음에 부를 스킬을 확인한다

## 2. 기본 호출 순서 (처음부터 끝까지)

```
/aidlc                                   상태 확인 (처음이면 "AI-DLC 시작 전")
/aidlc-inception-workspace-detection     1  Greenfield / Brownfield 판정
  -> 승인 후 계속
(Brownfield) Reverse Engineering         2  기존 코드 분석 문서 9개
  -> 승인 후 계속
Requirements Analysis                    3  질문 파일 -> 답변 -> requirements.md
  -> 승인 후 계속
(조건부) User Stories                     4  계획 질문 -> 답변 -> stories.md, personas.md
  -> 승인 후 계속
Workflow Planning                        5  남은 stage 의 EXECUTE / SKIP 결정
  -> 승인 후 계속
(조건부) Application Design, Units Generation   6, 7
  -> INCEPTION 끝: /traceability-check inception (권장)
unit 마다 반복:
  (조건부) Functional Design, NFR Requirements, NFR Design, Infrastructure Design   8 ~ 11
  Code Generation                         12  PART 1 계획 승인 -> PART 2 코드, 테스트 생성
Build and Test                           13  빌드, 테스트 지침과 실행 결과
  -> CONSTRUCTION 끝: /traceability-check construction (권장)
(조건부) Operations 7 stage                14 ~ 20  배포 대상이 확인될 때만
```

- 각 stage 는 완료 메시지와 승인 메뉴로 끝난다. 사용자가 고르기 전에는 다음 stage 로 넘어가지 않는다
- 승인 메뉴에서 "승인 후 계속" (또는 "다음 Stage 로 진행") 을 고르면 실행 계획의 다음 EXECUTE stage 로 이어진다. 그래서 일반적으로는 첫 스킬 하나만 부르고 이후는 승인 응답만 하면 된다
- 조건부 stage 의 실행 여부는 Workflow Planning 의 실행 계획 (`aidlc-docs/inception/plans/execution-plan.md`) 이 정한다. 계획 승인 때 "건너뛴 Stage 추가" 로 바꿀 수 있다

## 3. 상황별 호출

| 상황 | 호출 | 결과 |
| --- | --- | --- |
| 지금 어디까지 했는지 | `/aidlc` | 상태 표, 다음 스킬, 추적 점검 권장 여부 |
| 특정 stage 로 이동 | `/aidlc-inception-requirements-analysis` 또는 `/aidlc req` | 진행 위치 변경 후 실행 (중간 stage 는 SKIP 표기) |
| 지난 stage 다시 하기 | `/aidlc-inception-user-stories` | 그 stage 와 뒤 stage 를 재오픈. 기존 산출물은 유지/수정/처음부터 중 선택 |
| unit stage 실행 | `/aidlc-construction-code-generation guardian-share` 또는 `/aidlc codegen guardian-share` | 그 unit 의 stage 실행 |
| 진행 위치를 바꾸지 않고 한 stage 만 | `/aidlc-construction-functional-design guardian-share --single` | 실행 후 `Single-Stage Runs` 에 기록 |
| INCEPTION 끝 점검 | `/traceability-check inception` | 요구 -> 스토리 -> 컴포넌트 -> Unit 연결 점검 |
| CONSTRUCTION 끝 점검 | `/traceability-check construction` | AC, NFR -> 구현 계획 -> 테스트 -> 실행 결과 연결 점검 |
| 점검을 독립 맥락에서 | `/traceability-check-agent construction` | 서브에이전트가 대조 (Claude Code 전용) |
| 세션을 새로 열었을 때 | `/aidlc` 후 안내된 스킬, 또는 "이어서 진행해 줘" | SessionStart hook (Claude Code) 또는 AGENTS.md 지침 (Codex) 이 상태 파일을 읽고 재개 |

## 4. 질문 파일에 답하는 법

- AI 는 채팅이 아니라 `aidlc-docs/.../*questions*.md` 또는 계획 파일에 객관식 질문을 만든다
- 각 질문의 `[Answer]:` 뒤에 선택지 문자를 적고 "완료" 라고 알린다. 맞는 선택지가 없으면 마지막 Other 를 고르고 내용을 적는다
- 선택지에 "(추천)" 이 붙어 있으면 "추천값으로 진행해 줘" 라고 답해도 된다. AI 가 추천안을 `[Answer]:` 에 기록하고 근거를 남긴다
- 모호한 답 (예: "상황에 따라", "섞어서") 은 후속 질문 파일로 다시 묻는다

## 5. 산출물 위치

```
aidlc-docs/
  aidlc-state.md                      진행 상태 (Stage Progress, Extension Configuration, Current Status)
  audit.md                            모든 입력, 응답, 승인 기록 (덧붙이기만)
  inception/
    reverse-engineering/              Brownfield 분석 9개 문서
    requirements/                     requirement-verification-questions.md, requirements.md
    user-stories/                     stories.md, personas.md
    plans/                            user-stories-assessment.md, story-generation-plan.md, execution-plan.md
    application-design/               (실행 시) components, unit-of-work 등
  construction/
    plans/                            {unit}-functional-design-plan.md, {unit}-code-generation-plan.md
    {unit}/functional-design/         business-rules.md, business-logic-model.md, domain-entities.md
    {unit}/code/                      코드 요약 (markdown 만, 코드는 프로젝트 루트)
    build-and-test/                   빌드, 테스트 지침과 요약
  verification/                       phase-check-inception.md, phase-check-construction.md
```

- 애플리케이션 코드는 항상 프로젝트 원래 구조에 둔다. `aidlc-docs/` 에는 문서만 둔다

## 6. 규칙 요약 (core-workflow.md)

| 규칙 | 내용 |
| --- | --- |
| 승인 대기 | 모든 stage 는 완료 메시지 뒤 사용자 승인을 받아야 다음으로 간다 |
| 완료 메시지 고정 | stage 규칙 파일의 메시지와 메뉴를 그대로 쓴다 |
| 감사 기록 | 사용자 입력은 원문 그대로, 응답과 승인은 timestamp 와 함께 audit.md 에 덧붙인다 |
| 체크박스 | 계획 파일의 Step 을 끝내면 같은 상호작용 안에서 `[x]` 로 바꾼다 |
| AI 점검 (ko+dx 확장) | INCEPTION, CONSTRUCTION stage 는 완료 메시지 바로 위에 `common/stage-checklists.md` 점검 결과 블록을 붙인다 |
| 확장 opt-in | Requirements Analysis 에서 보안, 복원력, 속성 기반 테스트 확장 사용 여부를 묻고 `aidlc-state.md` 에 기록한다 |
| 코드 위치 | 코드는 프로젝트 루트 구조, 문서는 `aidlc-docs/` |

## 7. Codex 에서 다른 점

| 항목 | Claude Code | Codex |
| --- | --- | --- |
| 스킬 위치 | `.claude/skills/` | `.agents/skills/` (사용자 공통은 `~/.agents/skills/`) |
| 호출 | `/aidlc` | `$aidlc` 또는 `/skills` |
| 규칙 로드 | `CLAUDE.md` 의 `@.aidlc-rule-details/core-workflow.md` import | `AGENTS.md` 의 AI-DLC 절이 core-workflow.md 를 읽도록 지시 |
| 입력 자동 기록 | hook (`aidlc_audit.py`) | 없음. AI 가 규칙대로 직접 기록 |
| 세션 재개 안내 | SessionStart hook | AGENTS.md 지침 (상태 파일 먼저 읽기) |
| 진행 위치 표시 | statusLine | 없음. `$aidlc` 로 확인 |
| 서브에이전트 점검 | `traceability-check-agent` | 없음. `traceability-check` 사용 |
| 스킬 인자 | `$ARGUMENTS` 자리에 자동 치환 | 치환 없음. 스킬 이름 뒤에 쓴 인자를 AI 가 읽어 해석 |
| 직접 호출 전용 표시 | frontmatter `disable-model-invocation: true` 로 자동 호출 막음 | Codex 문서에 없는 필드라 효과를 보장하지 않음. 요청이 스킬 설명과 맞으면 자동 호출될 수 있음. 막으려면 스킬 폴더에 `agents/openai.yaml` 을 두고 `policy.allow_implicit_invocation: false` 지정 |

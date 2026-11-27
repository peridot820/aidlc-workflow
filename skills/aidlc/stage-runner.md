# stage 실행 절차 (stage 스킬 공통)

- 호출: stage 스킬 `/aidlc-<phase>-<stage>` 또는 `/aidlc <별칭>` -> 그 stage 스킬 `SKILL.md` 의 표 값으로 이 절차 진행
- 진행 규칙의 기준 = `.aidlc-rule-details/core-workflow.md` 의 "공통 stage 진행 규칙" (감사 기록, 승인 대기, 완료 메시지 고정, 진행 추적, AI 점검) 과 공통 규칙 (질문 형식, 내용 검증)
  - stage 스킬은 "어디서 시작할지" 만 정하고, 진행 방식은 바꾸지 않음
- stage 내용은 스킬에 없음 -> 항상 표의 규칙 파일 (`.aidlc-rule-details/...`) 을 읽고 그 Step 대로 진행
- 순서 (이동 방향 판단) = [stage-map.md](stage-map.md)
- 도중 변경 (건너뛰기, 건너뛴 stage 추가, 다시 시작) 의 기준 = `common/workflow-changes.md`, 복구의 기준 = `common/error-handling.md`. 이 절차는 그 규칙을 스킬 호출에 맞춘 것

## 0. 규칙 로드 (대화에 아직 없을 때만)

스킬로 바로 들어오면 "Using AI-DLC" 시작 때 읽는 규칙이 대화에 없을 수 있다. 진행 전에 다음을 읽는다.

1. `core-workflow.md` 와 공통 규칙 4개: `common/process-overview.md`, `common/session-continuity.md`, `common/content-validation.md`, `common/question-format-guide.md`
2. 확장 (core-workflow "확장 로딩")
   - `aidlc-state.md` 에 `## Extension Configuration` 이 없음 -> `extensions/**/*.opt-in.md` 만 로드 (opt-in 질문은 Requirements Analysis 에서)
   - 있음 -> `Enabled = Yes` 인 확장의 규칙 파일 (`.opt-in.md` -> `.md`) 을 로드. `No` 인 확장은 로드하지 않음
   - 대응하는 `.opt-in.md` 가 없는 확장은 항상 로드
3. 환영 메시지 (`common/welcome-message.md`): `aidlc-state.md` 가 없고 대상이 Workspace Detection 일 때만 1회 표시
4. 앞 산출물 로드: `common/session-continuity.md` 의 "이전 Stage 산출물 불러오기" 목록대로 대상 stage 에 필요한 앞 산출물을 읽고, 무엇을 읽었는지 1~3줄로 요약
   - unit 별 stage 는 그 unit 의 설계 산출물 + `unit-of-work-dependency.md` 기준으로 그 unit 이 의존하는 unit 의 설계 산출물
   - Brownfield 면 `inception/reverse-engineering/` 산출물
5. 깊이: `inception/plans/execution-plan.md` 에 대상 stage 의 깊이 (minimal / standard / comprehensive) 가 있으면 그 값 사용 (`common/depth-levels.md`)

## 1. 인자 해석

| 인자 | 모드 |
| --- | --- |
| 없음 (unit stage 는 unit 만) | 이동 (3절) |
| `--single` 포함 | 단독 실행 (4절) |

- unit 이 필요한 stage (표 `unit` = ✅ 필요) 에 unit 이 없음
  - `aidlc-docs/inception/application-design/unit-of-work.md` 에서 unit 목록을 읽어 번호와 함께 보여주고 선택 요청
  - `unit-of-work.md` 가 없고 Units Generation 이 SKIP 으로 기록됨 -> 단일 unit 프로젝트. `execution-plan.md` 나 `aidlc-state.md` 에 적힌 unit 이름을 쓰고, 없으면 프로젝트 이름을 unit 이름으로 제안해 확인을 받음 (이후 같은 이름을 계속 사용)
  - `unit-of-work.md` 가 없고 SKIP 기록도 없음 -> Units Generation 미실행 -> 2절 2지선다로 처리
- unit 이 필요 없는 stage 에 다른 인자 -> 무시하지 말고 "이 stage 는 unit 을 받지 않음" 안내 후 이동, 단독 실행 중 무엇인지 확인

## 2. 공통 사전 확인 (이동, 단독 실행)

1. `aidlc-docs/aidlc-state.md` 확인
   - 없음 + 대상이 Workspace Detection 이 아님 -> 진행하지 않고 `/aidlc-inception-workspace-detection` 먼저 실행 제안 (`--single` 도 동일)
   - 앞뒤가 맞지 않음 (current 가 여러 개, 완료 표시인데 산출물 없음, 산출물은 있는데 미완료 표시) -> `common/error-handling.md` 의 "재개 중 상태 불일치" 절차로 먼저 바로잡고, 무엇을 고쳤는지 사용자에게 보여 준 뒤 진행
2. 표의 "필요한 앞 산출물" 존재 확인 (폴더, 파일 존재만, "A 또는 B" = 하나만 있으면 충족)
   - "SKIP 기록" = `aidlc-state.md` 또는 `audit.md` 에 해당 stage SKIP 사유가 있음
3. 없는 산출물이 있으면 목록을 보여주고 2지선다로 묻기

```markdown
> **⚠️ 앞 산출물 없음 (Missing Prerequisites)**: [없는 경로 목록]
>
> 1️⃣ **앞 stage 먼저 실행 (Run Previous Stage First)** - `/aidlc-[phase]-[앞 stage]` 로 진행
> 2️⃣ **가정하고 진행 (Proceed with Assumptions)** - 가정 내용을 audit.md 에 기록하고 진행
```

- 사용자가 고를 때까지 진행하지 않음
- 2️⃣ 선택 -> 가정 내용을 먼저 사용자에게 보여주고, audit.md 에 `**Context**: [스킬 이름] 가정 진행 - [가정 목록]` 으로 기록

## 3. 이동 (인자 없음, unit 만)

### 3-1. 현재 위치 읽기

- 위치 = `aidlc-state.md` 의 `## Current Status` 의 Current Stage (없으면 Project Information 의 Current Stage)
- 값 끝이 `Complete` (예: `Units Generation Complete`) -> 그 stage 는 완료, 위치 = 그 stage 바로 뒤
- 값에서 앞머리 `INCEPTION - ` 등 phase 와 뒤의 `(<unit>)` 를 떼어 stage-map 의 상태 표기로 찾음

### 3-2. 방향 판단

- 순서 키 = stage-map 의 "순서 키" (unit 별 stage 는 unit 순서가 stage 번호보다 먼저)
  - 예: `Code Generation (U1)` -> `Functional Design (U2)` 는 앞으로, `Code Generation (U2)` -> `Functional Design (U1)` 는 뒤로

| 방향 | 처리 |
| --- | --- |
| 앞으로 (현재보다 뒤 stage) | 사이의 미완료 항목을 건너뜀. 그중 EXECUTE 예정 항목이 있으면 3-3 확인을 먼저 받음 |
| 현재 stage | 표기 변경 없이 그대로 진행 |
| 뒤로 (이미 지난 stage) | 3-4 확인을 먼저 받음 |

- 대상 stage 가 실행 계획에서 SKIP 이었음 -> "건너뛴 stage 추가" (`workflow-changes.md` 1절): 선행 stage 완료 여부 확인, `execution-plan.md` 에 EXECUTE 와 추가 사유 기록, `aidlc-state.md` 항목의 `SKIP` 을 `EXECUTE (추가)` 로 바꿈

### 3-3. 앞으로 이동 시 건너뛰기 확인

- 건너뛸 항목이 이미 SKIP 이거나 없으면 확인 없이 진행
- EXECUTE 예정 항목이 있으면 영향 (빠지는 산출물, 그 산출물을 앞 산출물로 쓰는 뒤 stage) 을 보여주고 묻기 (`workflow-changes.md` 2절, 명시적 확인 필수)

```markdown
> **⏭️ 계획된 stage 건너뛰기 (Skip Planned Stages)**: [건너뛸 stage 목록 (unit)]
> - 빠지는 산출물: [경로 목록]
> - 영향받는 뒤 stage: [목록과 이유 1줄씩]
>
> 1️⃣ **건너뛰고 이동 (Skip and Jump)** - 위 stage 를 SKIP 으로 표기하고 이동
> 2️⃣ **취소 (Cancel)** - 현재 위치에서 그대로 진행
```

- 1️⃣ 선택 -> 건너뛴 항목을 `- [ ] <상태 표기> - SKIP (stage 스킬 이동)` 으로 표기, `execution-plan.md` 의 해당 stage 에 SKIP 과 사유 기록. 나중에 자동 실행 안 함
- unit 별 stage 는 그 unit 만 SKIP 이므로 항목 줄은 그대로 두고 3-6 의 unit 진행 표기에 `<unit> 제외` 를 덧붙임 (`SKIP` 이라는 단어를 쓰면 상태 표시줄, `/aidlc` 가 그 줄 전체를 SKIP 으로 셈)

### 3-4. 뒤로 이동 시 영향 확인

- 영향 범위 = 대상 stage + 그 뒤의 완료 항목 (unit 별 stage 는 같은 unit 의 뒤 stage, 그리고 `unit-of-work-dependency.md` 에서 이 unit 에 의존하는 unit)
- 영향 범위를 보여주고 기존 산출물 처리 방법을 묻기 (`workflow-changes.md` 3, 4절)

```markdown
> **📂 지난 stage 다시 열기 (Reopen Completed Stage)**: [대상 stage (unit)]
> - 기존 산출물: [경로 목록]
> - 함께 재오픈되는 stage: [목록]
>
> 1️⃣ **유지 (Keep)** - 기존 산출물을 그대로 두고 승인 단계로 이동
> 2️⃣ **수정 (Modify)** - 기존 산출물을 바탕으로 고칠 부분만 진행
> 3️⃣ **처음부터 (Redo)** - 기존 산출물을 백업하고 규칙 파일의 첫 Step 부터 다시 진행
> 4️⃣ **취소 (Cancel)** - 현재 위치에서 그대로 진행
```

- 1️⃣ ~ 3️⃣ 선택 -> 대상과 함께 재오픈되는 완료 항목 (`[x]`) 을 `[ ]` + ` (재오픈)` 으로 표기
- 3️⃣ 선택 -> 덮어쓰기 전에 대상 stage 의 산출물과 계획 파일을 `{파일 이름}.backup.{YYYYMMDDTHHMMSSZ}` 로 복사하고, 계획 파일의 체크박스를 `[ ]` 로 되돌림 (`workflow-changes.md` 3절)
- 산출물 파일은 지우지 않음

### 3-5. 실행

1. 상태 파일 갱신: Current Stage = `[PHASE] - [상태 표기]` (unit 별이면 ` ([unit])`), 3-2 ~ 3-4 의 표기 반영
   - Current Stage, Next Stage 값 = stage 이름 (+ unit) 만. 설명, 괄호 메모는 audit.md 에 기록 (상태 표시줄, 세션 hook 이 이 값을 그대로 표시)
2. audit.md 끝에 덧붙이기 (3-7 형식)
3. 표의 규칙 파일을 읽고 첫 Step 부터 진행 (Operations 는 `operations/operations.md` 도 함께). 활성 확장 규칙은 이 stage 에 해당하는 것만 적용
4. 완료 메시지를 내기 전에 (Code Generation 은 계획 승인 질문 전에도)
   - `common/stage-checklists.md` 의 해당 항목 점검 -> 결과 블록을 완료 메시지 바로 위에 붙임 (INCEPTION, CONSTRUCTION 만)
   - 활성 확장이 있으면 확장 규칙 준수 요약 (규칙별 compliant / non-compliant / N/A) 포함. non-compliant 가 남으면 완료 메시지를 내지 않음 (차단 사항)
5. 규칙 파일의 완료 메시지, 승인 메뉴를 그대로 사용, 사용자 승인 전 진행 금지
6. 승인 후 이후 진행은 core-workflow 그대로 (실행 계획의 다음 EXECUTE stage)
   - 다음 stage 도 그 stage 의 완료 메시지에서 사용자 승인을 받아야 넘어감 (승인 없이 이어서 실행하는 stage 없음)
   - unit 별 stage: 한 unit 의 설계와 Code Generation 을 모두 끝낸 뒤 다음 unit 으로 (core-workflow "Unit 별 반복")
   - phase 경계 (INCEPTION 마지막 실행 stage 승인 직후, Build and Test 승인 직후): 다음 stage 를 시작하기 전에 "추적 점검: `/traceability-check inception` (또는 `construction`) 을 실행할 수 있음" 을 1줄로 안내. 점검을 대신 실행하지 않음 (사용자가 스킬을 직접 호출, hook 자동 실행 없음)

### 3-6. unit 별 stage 진행 표기

`aidlc-state.md` 의 Stage Progress 는 stage 마다 한 줄이라 unit 별 완료를 따로 담지 못한다. unit 이 여러 개면 다음처럼 표기한다.

```markdown
- [ ] Functional Design - EXECUTE (완료: U1)
- [ ] Code Generation - EXECUTE (완료: U1, U2 제외)
- [x] NFR Requirements - EXECUTE (완료: U1, U2)
```

- 규칙 파일의 "이 unit 의 stage 를 완료로 표시" = 괄호의 완료 목록에 unit 추가
- 실행 대상 unit 이 모두 완료 (또는 제외) 되면 `[x]` 로 바꿈. unit 이 하나면 괄호 없이 바로 `[x]`
- 재오픈은 괄호에서 그 unit 을 빼고 `[x]` 였으면 `[ ]` + ` (재오픈)` 으로 되돌림

### 3-7. audit 기록 형식

```markdown
## stage 스킬 이동 (Stage Jump)
**Timestamp**: [ISO 8601]
**User Input**: "[사용자 입력 원문 전체]"
**AI Response**: "[방향] [이전 Current Stage] -> [대상 stage], SKIP 표기: [목록 또는 없음], 재오픈: [목록 또는 없음], 백업: [목록 또는 없음]"
**Context**: /[스킬 이름] 이동

---
```

- 3-3 건너뛰기, 3-4 재오픈, 건너뛴 stage 추가가 있었으면 `workflow-changes.md` 의 `## Change Request - [Stage Name]` 형식 항목을 이어서 하나 더 남김 (영향 평가, 사용자 확인 원문, 바뀐 파일)
- UserPromptSubmit hook 이 이번 입력 원문을 이미 기록했다는 안내를 받았으면 `**User Input**: (hook 기록 [Timestamp])` 로 대신 (중복 기록 금지)
- audit.md 는 덧붙이기만 (전체 덮어쓰기 금지)

## 4. 단독 실행 (`--single`)

- 0절 규칙 로드 -> 2절 사전 확인 -> 규칙 파일대로 진행 -> 3-5 의 4, 5 (AI 점검, 확장 준수 요약, 완료 메시지, 승인) 까지 수행 후 멈춤
- 상태 파일의 Current Stage, Next Stage, Stage Progress 체크는 바꾸지 않음
- 기존 산출물이 있으면 3-4 와 같은 유지 / 수정 / 처음부터 / 취소 4지선다를 먼저 물음 (재오픈 표기는 하지 않음, 처음부터는 백업 후 덮어씀)
- 승인 후 `aidlc-state.md` 끝의 `## Single-Stage Runs` 절에 1줄 추가 (절이 없으면 만들기)

```markdown
## Single-Stage Runs
- [ISO 8601] [상태 표기] ([unit]) - [승인 | 변경 요청 중단] - 산출물: [경로]
```

- audit.md 기록은 3-7 형식, 제목만 `## stage 스킬 단독 실행 (Single-Stage Run)`, Context = `/[스킬 이름] --single`
- 완료 메시지의 "다음 Stage 로 진행 (Continue to Next Stage)" 선택 시 다음 stage 로 넘어가지 않고 `/aidlc` 상태 안내 출력으로 마무리

## 금지

- 1.0 규칙 파일 내용을 생략하거나 스킬 내용으로 대신하기
- 사용자 선택 없이 SKIP, 재오픈, 가정 진행, 건너뛴 stage 추가 결정
- 산출물 파일 삭제, 백업 없이 처음부터 덮어쓰기
- 활성 확장 규칙의 non-compliant 를 남긴 채 완료 메시지 제시

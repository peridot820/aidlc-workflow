---
name: aidlc-inception-units-generation
description: AI-DLC 🔵 INCEPTION 7. Units Generation (작업 단위 나누기) stage 를 1.0 규칙대로 진행. 인자 없이 = 이 stage 로 이동 (workflow 진행 위치 변경), --single = 이 stage 만 실행하고 진행 위치 유지. 사용자가 /aidlc-inception-units-generation 로 직접 호출할 때만 사용.
argument-hint: "[--single]"
disable-model-invocation: true
---

# /aidlc-inception-units-generation

| 항목 | 값 |
| --- | --- |
| stage | 🔵 INCEPTION 7. Units Generation (작업 단위 나누기) |
| 상태 표기 | Units Generation |
| 규칙 파일 | `.aidlc-rule-details/inception/units-generation.md` |
| 실행 조건 | CONDITIONAL |
| unit | - |
| 필요한 앞 산출물 | `inception/application-design/components.md` (규칙 파일 선행 조건: Application Design 필수), `inception/plans/execution-plan.md` |
| 참고 | 실행한 경우 `inception/user-stories/stories.md` (스토리를 unit 에 매핑) |
| 만드는 산출물 | `inception/application-design/unit-of-work*.md`, `inception/plans/unit-of-work-plan.md` |

- 인자: `$ARGUMENTS` (`--single` 포함 = 단독 실행, 없음 = 이동)
- 경로는 `aidlc-docs/` 기준, `{unit}` = unit 이름
- 진행: `../aidlc/stage-runner.md` (이 스킬 폴더 기준) 를 읽고 위 표 값으로 그 절차대로 진행
- 같은 이동 · 단독 실행을 `/aidlc units` 로도 호출 가능

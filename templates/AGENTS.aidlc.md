<!-- aidlc-workflow:begin -->
## AI-DLC

- 사용자가 "Using AI-DLC, ..." 로 개발을 요청하거나 `$aidlc` 계열 스킬을 부르면, 작업 전에 `.aidlc-rule-details/core-workflow.md` 를 처음부터 끝까지 읽고 그 규칙을 따른다
- 상세 규칙 경로는 프로젝트 루트의 `.aidlc-rule-details/` 기준이다
- 진행 상태는 `aidlc-docs/aidlc-state.md`, 기록은 `aidlc-docs/audit.md` 에 둔다. 세션을 새로 시작하면 두 파일을 먼저 읽고 이어서 진행한다
- 이 환경에는 입력 자동 기록 hook 이 없다. 사용자 입력 원문은 core-workflow.md 의 "감사 기록" 규칙대로 직접 audit.md 에 기록한다
- 스킬 안의 `/aidlc-...` 표기는 Codex 에서 `$aidlc-...` 로 부른다
<!-- aidlc-workflow:end -->

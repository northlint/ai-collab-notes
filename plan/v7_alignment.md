# V7 对照表 — KB 修订表述 ↔ skill 现文本（Phase 1 物证）

> 核对日期：2026-07-06。skill 路径：`~/.claude/commands/`。

| Phase 1 项 | KB 修订后表述 | skill 依据 (file:line) | 核对 |
|---|---|---|---|
| 1.1 §4.4 计划阶段闭环 | must-fix 直接修订计划文档 → 增量 re-review 至 APPROVE，不落盘、修好的计划就是闭环 | plan-review.md:81-83 | ✅ 语义一致 |
| 1.2 §10.1 仅 change_review 落盘 | `plan/reviews/` 只含 change_review_pending/history | plan-review.md:83（"不落盘任何 pending"）+ change-review.md Step 5（写 change_review_pending.md） | ✅ |
| 1.3 §10.2 状态三态 + 人裁决 | OPEN / ACCEPTED / WONTFIX，后两者需人裁决附理由；归档记 resolved | change-review.md:135（Status 三态 + 需用户裁决）、:159（模板行）、:137（防无穷债） | ✅ |
| 1.4 §4.3 表删 PR-UNRESOLVED | Change Review 分类无 PR 闭环类目 | change-review.md:122 起汇总表（Plan gaps/Correctness/Convention/Gate/Recurring，无 PR 行） | ✅ |
| 1.5 §12 职责描述 | change-review = diff + 机械闸门自证执行（假绿防御）+ 判断审查 + 写 pending | change-review.md:51（假绿防御原文） | ✅ |
| 1.6 #18 模板 | verdict 后注明 must-fix=直接修计划 + 增量 re-review，无状态跟踪 | plan-review.md:81-83 | ✅ |
| 1.7 #19 模板 | 无 Plan Review Closure/PR 行；状态三态 | change-review.md:122/:135/:159 | ✅ |
| 1.8 #17 模板 | history status = resolved/accepted/wontfix | change-review.md:159 + commit.md 归档格式 | ✅ |
| 1e 词表清扫 | 全库仅 2 处命中，均为 §4.4 有意历史叙述（V1 豁免项） | — | ✅ 已逐条确认 |

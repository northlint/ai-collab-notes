# KB 经验回流计划 — 工程侧一手经验回填（Tier 1+2）

> 日期：2026-07-06 · 状态：待 review
> 背景：应用户授权，扫描 `~/Desktop` 下 money/shop/other 三个项目集群约 30 份一手治理文档（技术债/decisions-log/review history/lessons），提炼出 35 条候选，经抽查核实、去重、分档后，本轮收录 **Tier 1（两个独立项目交叉验证）+ Tier 2（高价值单源）共 15 条工程侧经验**。Tier 3（product-spec 的 BMAD 框架 + 产品侧决策记录，14 条）用户裁决暂不处理，不在本计划范围。

## 非目标

- 不处理 Tier 3（产品侧治理集群）——范围决策未定，独立留档不动。
- 不新增章节——15 条全部落入既有 01-09 + 案例库 + 模板库，不新开编号。
- 不做无关的表达润色——只加这 15 条内容。

## 真相源（每条的一手出处，写作时对照，不凭复述）

| 编号 | 出处 | 已抽查 |
|---|---|---|
| A（Tier1）| `money/loan-app/specs/reviews/change_review_history.md` + `shop/pomogo_native/specs/reviews/change_review_history.md`（两项目独立 RECURRING ×12-13+ 记录） | ✅ |
| B（Tier1）| `money/loan-app/specs/technical_debt.md` §B + `shop/pomogo_native/specs/technical_debt.md` 顶部约定 | ✅ |
| C | `shop/pomogo_native/CLAUDE.md`「SPM 包/Build Tool Plugin 仅用户 Xcode GUI 添加」 | ✅ |
| D | `shop/pomogo_native/specs/technical_debt.md` C17（lint warning 分类处置） | 未抽查，agent 转述 |
| E | `shop/pomogo_native/specs/reviews/change_review_history.md`（Konsist 规则 wildcard import 盲点，phase 06-09） | 未抽查，agent 转述 |
| F | `shop/pomogo_native/specs/reviews/change_review_history.md`（Phase 10 CR-06，OverlayWindow hitTest nil-self bug） | 未抽查，agent 转述 |
| G | `money/loan-vue/plan/reviews/change_review_history.md`（2026-06-24 creditNeedReCredit，会话污染编造契约） | 未抽查，agent 转述 |
| H | `shop/pomogo_native/specs/reviews/change_review_history.md`（Phase 08 Round2，18 处 scheme/device 字面量漏改） | 未抽查，agent 转述 |
| I | `shop/pomogo_native_poc/CLAUDE.md`「全流程提速」worktree 隔离 | 未抽查，agent 转述 |
| J | `money/loan-app/specs/code_quality_lessons.md`「test 名与 body 契约对齐」 | ✅ |
| K | `money/loan-poc-mjl/plan/reviews/change_review_pending.md` CR-01/CR-03（OTP 组件半抽取） | ✅ |
| L | `money/loan-vue/plan/reference/decisions-log.md` + `conventions-rework.md` | 未抽查，agent 转述 |
| M | `money/loan-vue/plan/reference/workflow.md` L-T5 + change_review_history 2026-06-24 | 未抽查，agent 转述 |
| N | `money/loan-autofix/plan/reviews/plan_review_pending.md` PR-04 | ✅ |
| O | `shop/product-spec/discovery/03-discussions/2026-04-04-communication-notes.md`（金字塔结构） | 未抽查，agent 转述 |

**执行时纪律**：写入前对"未抽查"的 9 条逐条打开出处文件核实原文，与 A/B/C/J/K/N 一视同仁——不能因为已抽查 6 条就对其余 9 条降低举证标准。

## 落位方案（概念 ownership，不重复定义）

| 目标文件 | 落位条目 | 方式 |
|---|---|---|
| `02_上下文治理.md` | L, O | §3 附近增补「反转决策的重评触发点」小节；§7 附近增补「文档金字塔结构」一句+要点 |
| `03_下层执行.md` | I | §5 子 agent 分工附近，补 worktree 物理隔离作为并行写操作的通用技巧（不限定于无人值守） |
| `04_审查纠偏.md` | F, M；J 的技术改良并入既有 §9.3 | §4.1 或新增 9.5 案例（F：phase 收尾 smoke 占位）；§7 附近补审查强度按风险类别设下限（M）；§9.3 补充"codebase 内标识符引用"的 git grep 校验技巧（J 的可操作部分，不新开条目，与既有"外部引用编造"合并成同一根因的两种表现） |
| `05_诊断方法论.md` | G | §1 三条纪律，补 1.4「上下文疑似污染时不可信任已有推断，需独立重新取证」 |
| `06_技术债与经验回流.md` | B（Tier1） | §3/§5 附近新增「延后原因分类」维度（与 P0-P3 严重度正交） |
| `07_工具链治理.md` | A（Tier1）, D, E, H | §2 执法层级补"复发计数升级需跨层级，拆穿'升级=需要CI'假等价"（A）；§4 假绿防御补两个新形态（D 决策噪声vs真实信号、E 双探针验证）；新增小节"消除可漏改表面积：模板化收敛分散字面量"（H） |
| `08_长任务_loop_cron_无人值守.md` | N | Worker 相关部分补资源效率：软链主仓依赖+按需重建 |
| `A_案例库.md` | C, J（新案例部分）, K | 三个新案例：①原生工程 GUI-only 写入边界；②断言剧场（测试名与 body 契约错位）；③组件半抽取制造隐蔽重复债 |
| `B_模板库.md` | 配合 B | 模板 #4 技术债模板加「延后原因类型」字段（业务未触发/主动拒绝/临时遗漏） |

## 执行拆解（每文件一个 commit，参照上轮修订纪律）

1. **Commit 1**：`06_技术债与经验回流.md` + `B_模板库.md`（B，Tier1 之一，含模板同步）
2. **Commit 2**：`07_工具链治理.md`（A(Tier1) + D + E + H，四点集中在同一章）
3. **Commit 3**：`02_上下文治理.md`（L + O）
4. **Commit 4**：`03_下层执行.md`（I）
5. **Commit 5**：`04_审查纠偏.md`（F + M + J 技术改良并入 §9.3）
6. **Commit 6**：`05_诊断方法论.md`（G）
7. **Commit 7**：`08_长任务_loop_cron_无人值守.md`（N）
8. **Commit 8**：`A_案例库.md`（C + J新案例 + K，三个案例一次性加完）

每条内容后标注一手来源（file 路径，不含用户目录外可分发的敏感信息——按 V2 闸门要求脱敏为项目代号或直接省略具体路径，只保留"某原生 App 项目""某 H5 重写项目"这类描述，因为具体路径属于用户私有目录，不应出现在面向他人分发的 KB 正文里）。

## 验收标准

| # | 检查 | 标准 |
|---|---|---|
| V1 | 专名与路径零泄露 | 沿用现有全库 grep：`loan\|panaji\|pomogo\|...\|/Users/\|~/Desktop` 严格 0 命中（KB 正文不引用用户私有项目名/路径，只用"某原生 App 项目"等代号） |
| V2 | 概念不重复定义 | 每条新内容只在 ownership 表指定的唯一位置定义，其余相关处（如有）只加一句 + 内链，不重新展开 |
| V3 | 篇幅 | 单文件单次增补 ≤60 行（沿用上轮预算） |
| V4 | 内链/编号引用有效 | 沿用现有 `check_sync.sh` 之外，额外跑一次内链提取校验 |
| V5 | 举证 | 15 条全部完成"执行时纪律"里要求的逐条原文核实，未抽查的 9 条在此轮核实后同样打勾 |
| V6 | git 历史 | 8 个 commit，conventional + trailer |

## 风险

| 风险 | 缓解 |
|---|---|
| J 的技术改良并入既有 §9.3 可能改动原有措辞，需谨慎不破坏原案例 | 只追加，不删改原有反模式/正解描述 |
| 用户私有路径脱敏不彻底 | V1 机械闸门 + 写作时统一用代号，不写具体项目名 |
| 9 条未抽查内容核实后发现与 agent 转述有出入 | 以核实结果为准改写措辞，若发现失实直接从计划剔除该条，不强行保留 |

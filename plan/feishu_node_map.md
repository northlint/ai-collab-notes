# 飞书节点映射表（本地专属，不进分发物）

> 知识空间：AI协作经验（`space_id: 7659321558577646553`）
> 用途：本地文件 ↔ 飞书文档 token 的对应关系，AI 编辑时"fetch → 改 → overwrite"要用这张表定位目标文档，不用每次现查。

| 本地文件 | 飞书 wiki 节点 URL | node_token | obj_token (docx) |
|---|---|---|---|
| `00_总纲.md` | https://zifsoszbjz0.feishu.cn/wiki/UMIEwBvqZimQpTkvjQ1c0XuNnfc | `UMIEwBvqZimQpTkvjQ1c0XuNnfc` | `AvH5dugDvoWhf6xoKHhcH78LnQd` |
| `01_上层定法.md` | https://zifsoszbjz0.feishu.cn/wiki/Cmgtwtzq3i98U7k23frc28DJnFb | `Cmgtwtzq3i98U7k23frc28DJnFb` | `YwZwd7q9MoB6RoxOCxzcus0ZnGb` |
| `02_上下文治理.md` | https://zifsoszbjz0.feishu.cn/wiki/AO8WwkEijiB2aZkoFvAc4TBWnxc | `AO8WwkEijiB2aZkoFvAc4TBWnxc` | `Y1fldlvJCoPIAcx4JTUcgGP2nTb` |
| `03_下层执行.md` | https://zifsoszbjz0.feishu.cn/wiki/RnahwX8tKiWQGEksxlOc2XnBnXc | `RnahwX8tKiWQGEksxlOc2XnBnXc` | `HhVHd25NOoBwKMxQMIsc7beHnRd` |
| `04_审查纠偏.md` | https://zifsoszbjz0.feishu.cn/wiki/RjrGwOrfqiN45IkaoFcchKqvnvc | `RjrGwOrfqiN45IkaoFcchKqvnvc` | `VRn4d3hEYowmAhxVvVdcQeBpnfe` |
| `05_诊断方法论.md` | https://zifsoszbjz0.feishu.cn/wiki/P8XAw00xzipk5CkIZSRcLZ0xnOh | `P8XAw00xzipk5CkIZSRcLZ0xnOh` | `KhNxdO01xo1lNixnebzcq7fxnef` |
| `06_技术债与经验回流.md` | https://zifsoszbjz0.feishu.cn/wiki/VtBhwZLELiR5PZk2fYocRg1bnId | `VtBhwZLELiR5PZk2fYocRg1bnId` | `QC2kdj4c0otLhRx7MR9cAZsrnFb` |
| `07_工具链治理.md` | https://zifsoszbjz0.feishu.cn/wiki/RrCEwmISqiSysQkmz3ecbxkhnwh | `RrCEwmISqiSysQkmz3ecbxkhnwh` | `LnZzddYjXo7EmKx9yq6cnIq4nNK` |
| `08_长任务_loop_cron_无人值守.md` | https://zifsoszbjz0.feishu.cn/wiki/LVBmwPpSai0SnokuyY6csulhnsh | `LVBmwPpSai0SnokuyY6csulhnsh` | `QzsDdenU3o5MVfxk4Rcc1e8hnbf` |
| `09_迁移与重写治理.md` | https://zifsoszbjz0.feishu.cn/wiki/L7jzwDbspirLyLk0U6AcWah2nSc | `L7jzwDbspirLyLk0U6AcWah2nSc` | `YGnLdpAzUoxw7WxxH4mc41Mzndg` |
| `A_案例库.md` | https://zifsoszbjz0.feishu.cn/wiki/LgCCwPMXTiVugrkORtuclcAbnkh | `LgCCwPMXTiVugrkORtuclcAbnkh` | `GDH1dbo4WoMlHDxGgAWccuNenjg` |
| `B_模板库.md` | https://zifsoszbjz0.feishu.cn/wiki/FNJIwUVyviwu1Gk6hLMcmuUknjg | `FNJIwUVyviwu1Gk6hLMcmuUknjg` | `C2prdPW54ol193xwGWLcQiytnor` |
| `README.md` | https://zifsoszbjz0.feishu.cn/wiki/Iv6Ew3Qwki2uUtk2TutcIXnGnVd | `Iv6Ew3Qwki2uUtk2TutcIXnGnVd` | `P5uAdmzTPo87sDxvJTFcwGSenne` |

## 日常发布流程

```bash
# 改前刷新（轻量习惯，防止漏掉自己在飞书 App 里的手改）
lark-cli docs +fetch --api-version v2 --doc "<obj_token>" --as user

# 本地按原有方式编辑 + 跑检查

# 写回（本地相对链接 ./xx.md 飞书解析不了会直接丢失，需要先换成上表的绝对 wiki url 再发布；
# 无跨章节链接的文件可以直接拿本地原文发布）
lark-cli docs +update --api-version v2 --doc "<obj_token>" --command overwrite \
  --content "@<本地文件>" --doc-format markdown --as user
```

## 已知格式转换限制

- **相对链接会被丢弃**：`[text](./02_xxx.md)` 这种相对路径链接，飞书 markdown 导入时会静默丢弃 href，只留纯文本，不报错也不留痕迹——发布前必须先把涉及跨章节链接的文件里的相对路径换成本表对应的绝对 wiki url，否则链接会无声消失。
- **绝对 http(s) 链接可以正常转换为超链接**，本次验证过。
- **本地文件的相对链接保持不变**，只在发布（overwrite）这一步做临时替换，不污染本地工作副本——本地继续保留 `./0X_xxx.md` 相对路径，供本地工具/离线阅读使用。

## README.md 的特殊发布规则：标题替换

知识空间本身就叫"AI协作经验"，`README.md` 的飞书入口页如果标题也叫"AI协作经验"，会和空间名重复。所以 `README.md` 发布时额外做一步**仅发布副本生效**的标题替换：

- 本地 `README.md` 的 H1 **保持不变**，继续是 `# AI 协作经验`（GitHub/本地阅读场景下 README 首行应该是项目名，这是惯例）。
- 发布副本把首行替换成 `# 导读`，再 `overwrite` 写回飞书——即飞书入口页标题显示为"导读"，本地文件标题不受影响。
- 这是和"相对链接→绝对链接"同一类"发布时转换，不改本地源"的操作，一并在发布 README 前做：

```bash
sed '1s/.*/# 导读/' README.md > 发布副本   # 配合上面的相对链接替换一起做
```

下次改动 README.md 后发布，别忘了这一步——只做链接替换、漏做标题替换，会让飞书入口页标题变回"AI 协作经验"。

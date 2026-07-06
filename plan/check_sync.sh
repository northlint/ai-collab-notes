#!/bin/bash
# 比对 skill 现文本哈希与 plan/sync_baseline.md 登记的基线，漂移即列出。
# 用法：作者改 skill 后或 KB commit 前手动跑：bash plan/check_sync.sh
base="$(dirname "$0")/sync_baseline.md"
drift=0
while IFS='|' read -r _ file hash _; do
  file=$(echo "$file" | xargs); hash=$(echo "$hash" | xargs)
  [ -z "$file" ] || [ "$file" = "文件" ] || [[ "$file" == -* ]] && continue
  p="$HOME/.claude/commands/$file"
  [ -f "$p" ] || { echo "缺失: $p"; drift=1; continue; }
  cur=$(md5 -q "$p")
  [ "$cur" = "$hash" ] || { echo "漂移: $file（基线 $hash → 当前 $cur）→ 检查 KB 对应章节是否欠同步"; drift=1; }
done < "$base"
[ $drift -eq 0 ] && echo "同步基线一致，无漂移。"
exit $drift

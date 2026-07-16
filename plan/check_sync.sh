#!/bin/bash
# 比对 skill 现文本哈希与 plan/sync_baseline.md 登记的基线，漂移即列出。
# 用法：作者改 skill 后或 KB commit 前手动跑：bash plan/check_sync.sh
# 退出码：0 = 无漂移；1 = 有漂移或异常（含核对 0 条的空跑）。
#
# 注意（历史 bug 教训）：macOS /bin/bash 3.2 在双引号内解析 `$var` 后紧跟
# 多字节字符（如全角括号）时，会把该字符的首字节吃进变量名，导致变量展开
# 为空 + 输出乱码。因此本脚本所有含变量的中文输出一律走 printf 格式串，
# 变量绝不与多字节字面量直接相邻。
set -u

base="$(cd "$(dirname "$0")" && pwd)/sync_baseline.md"
if [ ! -f "$base" ]; then
  printf '错误: 基线文件不存在: %s\n' "$base" >&2
  exit 1
fi

# 去首尾空白（纯 bash，兼容 3.2，不依赖 xargs 的引号语义）
trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

drift=0
checked=0

while IFS= read -r line || [ -n "$line" ]; do
  # 只处理表格行（以 | 开头）
  case "$line" in
    "|"*) ;;
    *) continue ;;
  esac

  # 解析 | 文件 | md5 | 章节 | ：按 | 切分，取第 2、3 个字段
  # （行首的 | 使第 1 个字段为空）
  IFS='|' read -r _skip file hash _rest <<EOF
$line
EOF
  file=$(trim "${file:-}")
  hash=$(trim "${hash:-}")

  # 跳过表头与分隔行
  [ -z "$file" ] && continue
  [ "$file" = "文件" ] && continue
  case "$file" in
    -*|:*) continue ;;
  esac

  checked=$((checked + 1))

  if [ -z "$hash" ]; then
    printf '错误: 基线行缺少 md5 字段: %s\n' "$file" >&2
    drift=1
    continue
  fi

  p="$HOME/.claude/commands/$file"
  if [ ! -f "$p" ]; then
    printf '缺失: skill 文件不存在: %s\n' "$p"
    drift=1
    continue
  fi

  cur=$(md5 -q "$p" 2>/dev/null)
  if [ -z "$cur" ]; then
    printf '错误: md5 计算为空: %s\n' "$p" >&2
    drift=1
    continue
  fi

  if [ "$cur" != "$hash" ]; then
    printf '漂移: %s（基线 %s → 当前 %s）→ 检查 KB 对应章节是否欠同步\n' "$file" "$hash" "$cur"
    drift=1
  fi
done < "$base"

if [ "$checked" -eq 0 ]; then
  printf '已核对 0 条\n'
  printf '错误: 基线表未解析出任何条目（空跑假绿防御），检查 sync_baseline.md 表格格式或本脚本。\n' >&2
  exit 1
fi

printf '已核对 %d 条\n' "$checked"
if [ "$drift" -eq 0 ]; then
  printf '同步基线一致，无漂移。\n'
fi
exit "$drift"

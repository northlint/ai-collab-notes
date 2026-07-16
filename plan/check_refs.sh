#!/bin/bash
# 交叉引用完整性校验：扫描仓库根目录正文 *.md（不含 plan/），校验三类引用的目标真实存在。
#   1) 《章名》§N / 《章名》§N.N     —— 章名 → 文件用分隔符归一化包含匹配推断，再查编号标题
#      归一化：两侧剥掉分隔类字符（、 ， , 空格 _ -），ASCII 大写转小写，再看
#      章名是否为候选文件名（去 .md）的子串；若 0 命中，第二级再在两侧剥连接词
#      「与」重试（如《长任务、Loop、Cron 与无人值守》→ 08_长任务_loop_cron_无人值守.md，
#      文件名无「与」，仅靠分隔符归一化无法命中）。0 命中 / 多命中 → 无法判定 warning。
#   2) [xx.md](./xx.md) §N / §N.N   —— 文件直接给出，查编号标题
#   3) 案例库 #N / 案例 #N          —— A_案例库.md 中存在 ^## N. 标题
# 标题判定：§N → 目标文件有 `^## N. `；§N.N → 目标文件有 `^### N.N `。
# 输出：违规（确定失败）/ 无法判定（warning，不算失败）。
# 退出码：有确定违规 1；只有 warning 或全过 0；核对 0 处引用（空跑假绿）1。
# 用法：bash plan/check_refs.sh
#
# 兼容 macOS /bin/bash 3.2。所有含变量的中文输出走 printf 格式串
# （3.2 在 "$var多字节字符" 相邻时会吃字节，见 check_sync.sh 头注）。
set -u
export LC_ALL=en_US.UTF-8   # 保证 grep/sed 多字节处理确定性（hook 环境可能无 locale）

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || { printf '错误: 无法进入仓库根目录: %s\n' "$root" >&2; exit 1; }
shopt -s nullglob

violations=0
warnings=0
checked=0

# 把小节号转成 grep -E 可用的转义形式（点号转义）
esc_re() { printf '%s' "$1" | sed 's/\./\\./g'; }

# 归一化：剥分隔类字符（顿号、全角逗号、半角逗号、空格、全角空格、下划线、连字符），
# ASCII 大写转小写（tr 只动 A-Z 字节，多字节字符不受影响）
normalize() {
  printf '%s' "$1" \
    | sed -e 's/、//g' -e 's/，//g' -e 's/,//g' -e 's/ //g' -e 's/　//g' -e 's/_//g' -e 's/-//g' \
    | tr 'A-Z' 'a-z'
}

# 第二级兜底：再剥连接词「与」（仅在第一级 0 命中时使用）
strip_conj() { printf '%s' "$1" | sed 's/与//g'; }

# 章名 → 候选文件匹配。结果写入全局 CH_HITS 数组。
match_chapter() {
  local name="$1" norm_name cand norm_base
  CH_HITS=()
  norm_name=$(normalize "$name")
  for cand in "${docs[@]}"; do
    norm_base=$(normalize "${cand%.md}")
    case "$norm_base" in
      *"$norm_name"*) CH_HITS+=("$cand") ;;
    esac
  done
  if [ "${#CH_HITS[@]}" -eq 0 ]; then
    norm_name=$(strip_conj "$norm_name")
    for cand in "${docs[@]}"; do
      norm_base=$(strip_conj "$(normalize "${cand%.md}")")
      case "$norm_base" in
        *"$norm_name"*) CH_HITS+=("$cand") ;;
      esac
    done
  fi
}

# heading_exists <目标文件> <小节号> ：§N → ^## N. ；§N.N → ^### N.N␣
heading_exists() {
  local f="$1" sec="$2" esc
  esc=$(esc_re "$sec")
  case "$sec" in
    *.*) grep -Eq "^### ${esc} " "$f" ;;
    *)   grep -Eq "^## ${esc}\. " "$f" ;;
  esac
}

report_violation() { # <源文件> <行号> <引用原文> <原因>
  printf '违规: %s:%s 「%s」 → %s\n' "$1" "$2" "$3" "$4"
  violations=$((violations + 1))
}
report_warning() { # <源文件> <行号> <引用原文> <原因>
  printf '无法判定(warning): %s:%s 「%s」 → %s\n' "$1" "$2" "$3" "$4"
  warnings=$((warnings + 1))
}

# 待扫描文件：仓库根目录正文 *.md（glob 不递归，天然排除 plan/）
docs=( *.md )
if [ "${#docs[@]}" -eq 0 ]; then
  printf '错误: 仓库根目录未找到任何 .md 文件。\n' >&2
  exit 1
fi

for f in "${docs[@]}"; do

  # ---- 类型 1：《章名》§N / §N.N ----
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    lineno="${entry%%:*}"
    ref="${entry#*:}"
    name=$(printf '%s\n' "$ref" | sed -E 's/^《([^》]+)》.*$/\1/')
    sec=$(printf '%s\n' "$ref" | sed -E 's/^.*§([0-9.]+)$/\1/')
    checked=$((checked + 1))

    match_chapter "$name"
    if [ "${#CH_HITS[@]}" -eq 0 ]; then
      report_warning "$f" "$lineno" "$ref" "章名归一化后仍匹配不到文件"
      continue
    fi
    if [ "${#CH_HITS[@]}" -gt 1 ]; then
      report_warning "$f" "$lineno" "$ref" "章名归一化后匹配到多个文件: ${CH_HITS[*]}"
      continue
    fi
    if ! heading_exists "${CH_HITS[0]}" "$sec"; then
      case "$sec" in
        *.*) pat="### ${sec} " ;;
        *)   pat="## ${sec}. " ;;
      esac
      report_violation "$f" "$lineno" "$ref" "目标 ${CH_HITS[0]} 中不存在标题「${pat}…」"
    fi
  done < <(grep -Eon '《[^》]+》[[:space:]]*§[0-9]+(\.[0-9]+)?' "$f")

  # ---- 类型 2：[xx.md](./xx.md) §N / §N.N ----
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    lineno="${entry%%:*}"
    ref="${entry#*:}"
    target=$(printf '%s\n' "$ref" | sed -E 's/^\]\(([^)]+)\).*$/\1/')
    target="${target#./}"
    sec=$(printf '%s\n' "$ref" | sed -E 's/^.*§([0-9.]+)$/\1/')
    checked=$((checked + 1))

    if [ ! -f "$target" ]; then
      report_violation "$f" "$lineno" "$ref" "目标文件不存在: ${target}"
      continue
    fi
    if ! heading_exists "$target" "$sec"; then
      case "$sec" in
        *.*) pat="### ${sec} " ;;
        *)   pat="## ${sec}. " ;;
      esac
      report_violation "$f" "$lineno" "$ref" "目标 ${target} 中不存在标题「${pat}…」"
    fi
  done < <(grep -Eon '\]\([^)]+\.md\)[[:space:]]*§[0-9]+(\.[0-9]+)?' "$f")

  # ---- 类型 3：案例库 #N / 案例 #N ----
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    lineno="${entry%%:*}"
    ref="${entry#*:}"
    num=$(printf '%s\n' "$ref" | sed -E 's/^.*#([0-9]+)$/\1/')
    checked=$((checked + 1))

    if [ ! -f "A_案例库.md" ]; then
      report_violation "$f" "$lineno" "$ref" "A_案例库.md 不存在"
      continue
    fi
    if ! grep -Eq "^## ${num}\. " "A_案例库.md"; then
      report_violation "$f" "$lineno" "$ref" "A_案例库.md 中不存在标题「## ${num}. …」"
    fi
  done < <(grep -Eon '案例库?[[:space:]]*#[0-9]+' "$f")

done

if [ "$checked" -eq 0 ]; then
  printf '已核对 0 处引用\n'
  printf '错误: 未扫出任何引用（本库引用很多，0 一定是脚本坏了 —— 空跑假绿防御）。\n' >&2
  exit 1
fi

printf '已核对 %d 处引用（违规 %d，无法判定 %d）\n' "$checked" "$violations" "$warnings"
if [ "$violations" -gt 0 ]; then
  exit 1
fi
printf '交叉引用校验通过。\n'
exit 0

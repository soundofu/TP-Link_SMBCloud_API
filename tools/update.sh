#!/usr/bin/env bash
# TP-LINK 商云接口文档更新流水线：抽取新版 PDF → 重新生成 doc/tplink-api/*.md → 与上一版对比出报告。
#
# 用法（Git Bash，在仓库任意位置执行）：
#   doc/tplink-api/_tools/update.sh <新版PDF> [<旧版PDF>] [--compare-only]
#
#   新版PDF       文件名需带日期，如 doc/TP-LINK商用云平台开放接口文档-2026-08-31.pdf
#   旧版PDF       省略时自动选 doc/ 下日期早于新版的最近一版
#   --compare-only 只出对比报告，不覆盖 doc/tplink-api/*.md（用于补做历史版本对比）
#
# 输出：报告目录（脚本结尾打印路径），包含
#   summary.txt    —— 接口数量、增删 Path、错误码增删、项目在用接口的兼容性速览
#   sections.txt   —— 按小节的内容差异（compare_sections.pl），需人工逐条确认
#   endpoints.txt  —— 项目代码在用的每个 Path 的差异（compare_endpoints.pl）
# 报告只是原始素材；CHANGELOG.md 条目需要人工/agent 阅读报告后撰写。
set -euo pipefail

TOOLS="$(cd "$(dirname "$0")" && pwd)"
DOC_DIR="$(dirname "$TOOLS")"
ROOT="$(cd "$DOC_DIR/../.." && pwd)"

NEW_PDF=""; OLD_PDF=""; COMPARE_ONLY=0
for a in "$@"; do
  case "$a" in
    --compare-only) COMPARE_ONLY=1 ;;
    *) if [ -z "$NEW_PDF" ]; then NEW_PDF="$a"; else OLD_PDF="$a"; fi ;;
  esac
done
[ -n "$NEW_PDF" ] && [ -f "$NEW_PDF" ] || { echo "用法: $0 <新版PDF> [<旧版PDF>] [--compare-only]" >&2; exit 1; }

date_of() { basename "$1" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "undated"; }
NEW_VER="$(date_of "$NEW_PDF")"
[ "$NEW_VER" != "undated" ] || { echo "新版 PDF 文件名必须带日期 YYYY-MM-DD" >&2; exit 1; }

if [ -z "$OLD_PDF" ]; then
  OLD_PDF="$(ls "$ROOT"/doc/TP-LINK商用云平台开放接口文档-*.pdf 2>/dev/null \
    | while read -r f; do d="$(date_of "$f")"; if [[ "$d" < "$NEW_VER" ]]; then echo "$d	$f"; fi; done \
    | sort | tail -1 | cut -f2)"
  [ -n "$OLD_PDF" ] || { echo "找不到早于 $NEW_VER 的旧版 PDF，请显式指定" >&2; exit 1; }
fi
OLD_VER="$(date_of "$OLD_PDF")"

WORK="$(mktemp -d)"
echo "新版: $NEW_VER  ($NEW_PDF)"
echo "旧版: $OLD_VER  ($OLD_PDF)"

# pdftotext 打不开中文路径，先复制
cp "$NEW_PDF" "$WORK/new.pdf"; cp "$OLD_PDF" "$WORK/old.pdf"
pdftotext -layout -enc UTF-8 "$WORK/new.pdf" "$WORK/new.txt"
pdftotext -layout -enc UTF-8 "$WORK/old.pdf" "$WORK/old.txt"

perl "$TOOLS/pdf2md.pl" "$WORK/new.txt" "$WORK/new_md" "$NEW_VER" 2> "$WORK/gen_new.log" || true
perl "$TOOLS/pdf2md.pl" "$WORK/old.txt" "$WORK/old_md" "$OLD_VER" 2> "$WORK/gen_old.log" || true
grep -E 'sections=|MISSING|RENUM' "$WORK/gen_new.log" | sed 's/^/[生成] /'
if grep -q MISSING "$WORK/gen_new.log"; then
  echo "!! 新版有小节未定位（MISSING），需先修 pdf2md.pl 的标题匹配再继续" >&2; exit 2
fi

# ---------- 报告 ----------
paths_of() { grep -oE '/(tums|vms|openapi|ams|cms|nms)/[A-Za-z0-9/_]+' "$1" | grep -E '/v[0-9]+/[A-Za-z]' | sort -u; }
paths_of "$WORK/old.txt" > "$WORK/paths_old.txt"
paths_of "$WORK/new.txt" > "$WORK/paths_new.txt"
where() { grep -F "\`$1\`" "$2/INDEX.md" | head -1 | awk -F'|' '{gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$3); print $2" "$3}'; }

errcodes() { cat "$1"/1.5-*.md 2>/dev/null | grep -oE '^\s*-[0-9]{4,7}\s+\S.*' | sed -E 's/^\s+//; s/\s{2,}/ /g' | sort -u; }
errcodes "$WORK/old_md" > "$WORK/ec_old.txt"
errcodes "$WORK/new_md" > "$WORK/ec_new.txt"

USED="$(grep -rhoE '"/(vms|tums|openapi|ams)/open/[A-Za-z0-9/_.-]*"' "$ROOT" \
  --include=*.java --include=*.js --include=*.vue --include=*.ts \
  --exclude-dir=node_modules --exclude-dir=target --exclude-dir=dist 2>/dev/null | tr -d '"' | sort -u)"

{
  echo "# $OLD_VER → $NEW_VER"
  echo "接口 Path 数：旧 $(wc -l < "$WORK/paths_old.txt")，新 $(wc -l < "$WORK/paths_new.txt")"
  echo; echo "## 删除的 Path"
  comm -23 "$WORK/paths_old.txt" "$WORK/paths_new.txt" | while read -r p; do echo "- $p  <- $(where "$p" "$WORK/old_md")"; done
  echo; echo "## 新增的 Path"
  comm -13 "$WORK/paths_old.txt" "$WORK/paths_new.txt" | while read -r p; do echo "- $p  <- $(where "$p" "$WORK/new_md")"; done
  echo; echo "## 删除的错误码"
  comm -23 <(cut -d' ' -f1 "$WORK/ec_old.txt" | sort -u) <(cut -d' ' -f1 "$WORK/ec_new.txt" | sort -u) \
    | while read -r c; do grep -m1 -- "^$c " "$WORK/ec_old.txt"; done
  echo; echo "## 新增的错误码"
  comm -13 <(cut -d' ' -f1 "$WORK/ec_old.txt" | sort -u) <(cut -d' ' -f1 "$WORK/ec_new.txt" | sort -u) \
    | while read -r c; do grep -m1 -- "^$c " "$WORK/ec_new.txt"; done
  echo; echo "## 项目在用接口（$(echo "$USED" | grep -c /) 个）"
  for p in $USED; do
    o=$(grep -cF "$p" "$WORK/old.txt" || true); n=$(grep -cF "$p" "$WORK/new.txt" || true)
    if [ "$n" = 0 ] && [ "$o" = 0 ]; then echo "- [两版均无] $p"
    elif [ "$n" = 0 ]; then echo "- [新版已删除!] $p"
    fi
  done
  echo "（未列出的在用接口两版都存在；字段级差异见 endpoints.txt）"
} > "$WORK/summary.txt"

perl "$TOOLS/compare_sections.pl" "$WORK/old.txt" "$WORK/new.txt" > "$WORK/sections.txt"
# shellcheck disable=SC2086
perl "$TOOLS/compare_endpoints.pl" "$WORK/old.txt" "$WORK/new.txt" $USED > "$WORK/endpoints.txt"

if [ "$COMPARE_ONLY" = 0 ]; then
  # 只删生成物（章节文件 1.*.md 与 INDEX.md），手写文件不动
  find "$DOC_DIR" -maxdepth 1 \( -name '1.*.md' -o -name INDEX.md \) -delete
  cp "$WORK"/new_md/*.md "$DOC_DIR/"
  echo "[生成] 已用 $NEW_VER 覆盖 $DOC_DIR/*.md（仅替换章节文件与 INDEX.md）"
fi

echo
cat "$WORK/summary.txt"
echo
echo "报告目录: $WORK"
echo "  sections.txt  $(grep -c '^###' "$WORK/sections.txt") 个小节有差异，$(grep -c '^ADDED' "$WORK/sections.txt") 个新增小节"
echo "  endpoints.txt 在用接口字段级差异（关注 +ids/-ids/+zh/-zh 行）"

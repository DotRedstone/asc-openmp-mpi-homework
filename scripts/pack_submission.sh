#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: bash scripts/pack_submission.sh <姓名> <学号> <报告PDF路径>"
  exit 2
fi

NAME="$1"
STUDENT_ID="$2"
REPORT_PDF="$3"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$REPORT_PDF" ]]; then
  echo "report pdf not found: $REPORT_PDF"
  exit 1
fi

SUBMIT_NAME="${NAME}_${STUDENT_ID}_ASC并行优化作业"
SUBMIT_DIR="$ROOT_DIR/submissions/$SUBMIT_NAME"
ARCHIVE="$ROOT_DIR/submissions/${SUBMIT_NAME}.tar.gz"

rm -rf "$SUBMIT_DIR"
mkdir -p "$SUBMIT_DIR/src" "$SUBMIT_DIR/results"

cp "$REPORT_PDF" "$SUBMIT_DIR/${NAME}_${STUDENT_ID}_ASC并行优化作业报告.pdf"
cp "$ROOT_DIR/src/merge_sort_omp.cpp" "$SUBMIT_DIR/src/"
cp "$ROOT_DIR/src/jacobi_omp.cpp" "$SUBMIT_DIR/src/"

if [[ -d "$ROOT_DIR/results" ]]; then
  find "$ROOT_DIR/results" -maxdepth 1 -type f -exec cp {} "$SUBMIT_DIR/results/" \;
fi

cat > "$SUBMIT_DIR/README.md" <<EOF
# $SUBMIT_NAME

- 姓名：$NAME
- 学号：$STUDENT_ID
- 报告：${NAME}_${STUDENT_ID}_ASC并行优化作业报告.pdf
- 优化代码：src/
- 运行结果：results/
EOF

tar -czf "$ARCHIVE" -C "$ROOT_DIR/submissions" "$SUBMIT_NAME"
echo "submission archive created: $ARCHIVE"

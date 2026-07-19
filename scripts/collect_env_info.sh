#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: bash scripts/collect_env_info.sh <姓名> <学号>"
  exit 2
fi

NAME="$1"
STUDENT_ID="$2"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/results"
OUT_FILE="$OUT_DIR/env_info.txt"

mkdir -p "$OUT_DIR"

{
  echo "# ASC OpenMP / MPI homework environment"
  echo
  echo "name=$NAME"
  echo "student_id=$STUDENT_ID"
  echo "date=$(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## repository"
  git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || true
  git -C "$ROOT_DIR" status --short 2>/dev/null || true
  echo
  echo "## system"
  uname -a || true
  echo
  echo "## cpu"
  lscpu 2>/dev/null || true
  echo
  echo "## memory"
  free -h 2>/dev/null || true
  echo
  echo "## compilers"
  which g++ || true
  g++ --version 2>/dev/null | head -n 3 || true
  echo
  echo "## make"
  make --version 2>/dev/null | head -n 2 || true
  echo
  echo "## openmp macro"
  echo | g++ -fopenmp -dM -E - 2>/dev/null | grep _OPENMP || true
  echo
  echo "## mpi optional"
  which mpicxx || true
  mpicxx --version 2>/dev/null | head -n 3 || true
  which mpirun || true
  mpirun --version 2>/dev/null | head -n 3 || true
} > "$OUT_FILE"

echo "environment info saved to $OUT_FILE"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

N="${N:-4096}"
STEPS="${STEPS:-180000}"
THREADS="${OMP_NUM_THREADS:-4}"
OUT_FILE="results/jacobi_long_${N}_${STEPS}.txt"
MODE="${MODE:-baseline}"

mkdir -p results

echo "[1/3] build"
make all

echo "[2/3] baseline estimate"
echo "This long run may take about one hour on a laptop-class CPU."
echo "Parameters: n=$N, steps=$STEPS"
echo "Mode: $MODE"
echo "Output file: $OUT_FILE"
echo

{
  if [[ "$MODE" == "baseline" || "$MODE" == "both" ]]; then
    echo "===== jacobi_baseline n=$N steps=$STEPS ====="
    date '+start=%Y-%m-%d %H:%M:%S %z'
    ./build/jacobi_baseline "$N" "$STEPS"
    date '+end=%Y-%m-%d %H:%M:%S %z'
    echo
  fi

  if [[ "$MODE" == "omp" || "$MODE" == "both" ]]; then
    echo "===== jacobi_omp n=$N steps=$STEPS threads=$THREADS ====="
    date '+start=%Y-%m-%d %H:%M:%S %z'
    OMP_NUM_THREADS="$THREADS" ./build/jacobi_omp "$N" "$STEPS"
    date '+end=%Y-%m-%d %H:%M:%S %z'
  fi
} | tee "$OUT_FILE"

echo "[3/3] long Jacobi log saved to $OUT_FILE"

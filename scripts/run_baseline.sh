#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p results

echo "[1/3] build"
make all

echo "[2/3] merge sort baseline"
{
  echo "===== merge_sort_baseline n=100000 ====="
  ./build/merge_sort_baseline 100000 2026
  echo
  echo "===== merge_sort_baseline n=1000000 ====="
  ./build/merge_sort_baseline 1000000 2026
} | tee results/merge_sort_baseline.txt

echo "[3/3] jacobi baseline"
{
  echo "===== jacobi_baseline n=512 steps=500 ====="
  ./build/jacobi_baseline 512 500
  echo
  echo "===== jacobi_baseline n=2048 steps=1000 ====="
  ./build/jacobi_baseline 2048 1000
} | tee results/jacobi_baseline.txt

echo "baseline logs saved in results/"

# ASC OpenMP / MPI 课后作业

本仓库用于发布 ASC 培训第三次课后作业：**CPU 并行优化入门实践**。

本次作业要求先运行串行 baseline，记录正确结果和运行时间，再在 CPU 上进行并行优化。重点不是“把线程数开大”，而是学会判断循环依赖、划分任务、验证正确性，并用数据说明优化是否真的有效。

## 1. 作业目标

完成本次作业后，你应该能够说明并证明自己完成了：

- 编译并运行 C++ baseline 程序；
- 记录机器环境、编译命令、运行命令和运行时间；
- 对同一份输入比较串行版本和并行版本的正确性；
- 使用 OpenMP 对 CPU 程序进行并行优化；
- 理解任务划分、同步开销、阈值设置和数据规模对加速比的影响；
- 将实验过程整理成结构清晰、可以复现的报告。

## 2. 基本规则

- 只能使用 CPU，不使用 GPU / CUDA；
- 必须先跑串行 baseline，再跑优化版本；
- 优化前后必须使用同一台机器、同一组输入、同一组参数；
- 每组实验建议至少运行 3 次，报告中给出平均时间；
- 不允许修改正确性检查逻辑来绕过验证；
- 如果某个大规模实验无法完成，需要在报告中说明机器配置、失败命令和原因。

## 3. 仓库结构

```text
asc-openmp-mpi-homework/
├── Makefile
├── README.md
├── docs/
│   ├── checklist.md
│   └── faq.md
├── scripts/
│   ├── collect_env_info.sh
│   ├── pack_submission.sh
│   └── run_baseline.sh
├── src/
│   ├── jacobi_baseline.cpp
│   ├── jacobi_omp.cpp
│   ├── merge_sort_baseline.cpp
│   └── merge_sort_omp.cpp
└── templates/
    └── report_template.md
```

`baseline` 文件用于建立串行对照；`omp` 文件是并行优化入口，初始代码保持可编译、可运行，后续需要在这些文件中完成优化。

## 4. 环境要求

请在 Linux / WSL2 / 远程服务器环境中完成。

需要能使用：

```bash
git --version
g++ --version
make --version
```

如果要完成 OpenMP 优化，需要当前编译器支持：

```bash
g++ -fopenmp --version
```

如果要尝试 MPI 拓展，可以额外检查：

```bash
mpicxx --version
mpirun --version
```

## 5. 克隆仓库

```bash
git clone https://github.com/DotRedstone/asc-openmp-mpi-homework.git
cd asc-openmp-mpi-homework
```

如果 GitHub 访问失败，先检查网络和代理。

## 6. 编译与快速运行

编译全部程序：

```bash
make all
```

快速运行一组 baseline：

```bash
bash scripts/run_baseline.sh
```

也可以手动运行：

```bash
./build/merge_sort_baseline 100000 2026
./build/merge_sort_omp 100000 2026

./build/jacobi_baseline 512 500
./build/jacobi_omp 512 500
```

其中排序程序参数为：

```text
数组规模 随机种子
```

Jacobi 程序参数为：

```text
网格边长 迭代步数
```

## 7. 作业一：并行归并排序

### 7.1 任务说明

本题提供串行归并排序 baseline：

```text
src/merge_sort_baseline.cpp
```

需要优化的文件：

```text
src/merge_sort_omp.cpp
```

初始版本可以正确运行，但还没有真正并行优化。需要在此基础上完成并行归并排序。

### 7.2 数据规模

至少运行以下三档规模：

| 规模 | 命令示例 |
| --- | --- |
| 小规模 | `./build/merge_sort_baseline 100000 2026` |
| 中规模 | `./build/merge_sort_baseline 1000000 2026` |
| 大规模 | `./build/merge_sort_baseline 10000000 2026` |

优化版本使用同样参数：

```bash
OMP_NUM_THREADS=4 ./build/merge_sort_omp 1000000 2026
```

可以额外测试不同线程数：

```bash
OMP_NUM_THREADS=1 ./build/merge_sort_omp 1000000 2026
OMP_NUM_THREADS=2 ./build/merge_sort_omp 1000000 2026
OMP_NUM_THREADS=4 ./build/merge_sort_omp 1000000 2026
OMP_NUM_THREADS=8 ./build/merge_sort_omp 1000000 2026
```

### 7.3 优化方向

可以尝试：

- 使用 OpenMP task 并行处理左右子区间；
- 设置任务递归阈值，避免任务过细；
- 减少临时数组重复分配；
- 比较不同线程数下的运行时间；
- 分析小规模数据为什么可能不加速。

### 7.4 正确性要求

程序输出中必须看到：

```text
sorted=OK
checksum=OK
```

如果优化版本速度更快但结果不正确，视为无效优化。

## 8. 作业二：二维热扩散 Jacobi 迭代优化

### 8.1 任务说明

本题提供一个简单的二维 stencil 计算。每一步迭代中，内部网格点由上下左右四个邻居平均得到：

```cpp
next[id] = 0.25 * (
    cur[id - n] + cur[id + n] +
    cur[id - 1] + cur[id + 1]);
```

串行 baseline：

```text
src/jacobi_baseline.cpp
```

需要优化的文件：

```text
src/jacobi_omp.cpp
```

### 8.2 数据规模

至少运行以下三档规模：

| 规模 | 参数 |
| --- | --- |
| 小规模 | `n=512, steps=500` |
| 中规模 | `n=2048, steps=1000` |
| 大规模 | `n=4096, steps=3000` |

命令示例：

```bash
./build/jacobi_baseline 512 500
OMP_NUM_THREADS=4 ./build/jacobi_omp 512 500
```

大规模可能运行时间较长。报告中需要说明每个规模是否完成、运行了多长时间，以及机器配置是否足以支撑该规模。

### 8.3 优化方向

可以尝试：

- 对外层循环使用 OpenMP 并行；
- 调整循环调度策略；
- 减少每步迭代中的额外拷贝；
- 改善缓存访问局部性；
- 测试不同线程数下的加速效果；
- 使用 MPI 按行分块作为拓展尝试。

### 8.4 正确性要求

优化版本需要与 baseline 的最终校验值接近。报告中需要记录：

- baseline 的 `checksum`；
- 优化版本的 `checksum`；
- 二者绝对误差；
- 是否满足误差不超过 `1e-6`。

## 9. 报告要求

每位同学提交一份 PDF 报告。建议正文控制在 5 到 10 页。

报告至少包含：

1. 基本信息；
2. 软硬件环境；
3. 编译方式和运行命令；
4. 作业一 baseline 结果；
5. 作业一优化方法与结果；
6. 作业二 baseline 结果；
7. 作业二优化方法与结果；
8. 正确性验证；
9. 加速比分析；
10. 总结与问题。

可以参考：

- [报告模板](templates/report_template.md)
- [完成检查清单](docs/checklist.md)
- [常见问题](docs/faq.md)

## 10. 提交材料

提交目录建议如下：

```text
姓名_学号_ASC并行优化作业/
├── 姓名_学号_ASC并行优化作业报告.pdf
├── src/
│   ├── merge_sort_omp.cpp
│   └── jacobi_omp.cpp
├── results/
│   ├── env_info.txt
│   ├── merge_sort_results.txt
│   └── jacobi_results.txt
└── README.md
```

可以使用脚本辅助打包：

```bash
bash scripts/pack_submission.sh <姓名> <学号> <报告PDF路径>
```

正式提交方式以通知为准。

## 11. 通过标准

基础通过需要满足：

- 能成功编译全部程序；
- 至少完成小规模和中规模 baseline；
- 至少完成小规模和中规模优化版本；
- 正确性检查通过；
- 报告中包含运行命令、运行时间、线程数和加速比；
- 能解释一次没有加速或加速不明显的现象。

优秀完成可以包括：

- 完成全部三档规模；
- 对不同线程数进行对比；
- 作业一合理设置任务阈值；
- 作业二有清晰的缓存或调度分析；
- 尝试 MPI 拓展并说明通信开销。

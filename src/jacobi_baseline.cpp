#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <string>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

void initialize(std::vector<double>& grid, int n) {
    std::fill(grid.begin(), grid.end(), 0.0);
    for (int j = 0; j < n; ++j) {
        grid[j] = 100.0;
        grid[(n - 1) * n + j] = 0.0;
    }
    for (int i = 0; i < n; ++i) {
        grid[i * n] = 50.0;
        grid[i * n + (n - 1)] = 25.0;
    }
}

double checksum(const std::vector<double>& grid) {
    double sum = 0.0;
    for (double x : grid) {
        sum += x;
    }
    return sum;
}

void jacobi_step(const std::vector<double>& cur, std::vector<double>& next, int n) {
    for (int i = 1; i < n - 1; ++i) {
        for (int j = 1; j < n - 1; ++j) {
            int id = i * n + j;
            next[id] = 0.25 * (cur[id - n] + cur[id + n] + cur[id - 1] + cur[id + 1]);
        }
    }
}

}  // namespace

int main(int argc, char** argv) {
    int n = 512;
    int steps = 500;

    if (argc >= 2) n = std::stoi(argv[1]);
    if (argc >= 3) steps = std::stoi(argv[2]);

    if (n < 3 || steps < 1) {
        std::cerr << "usage: " << argv[0] << " <n>=512 <steps>=500\n";
        return 2;
    }

    std::vector<double> cur(static_cast<std::size_t>(n) * n);
    std::vector<double> next(static_cast<std::size_t>(n) * n);
    initialize(cur, n);
    initialize(next, n);

    auto start = Clock::now();
    for (int t = 0; t < steps; ++t) {
        jacobi_step(cur, next, n);
        cur.swap(next);
    }
    auto finish = Clock::now();

    double seconds = std::chrono::duration<double>(finish - start).count();
    double sum = checksum(cur);

    std::cout << std::fixed << std::setprecision(10);
    std::cout << "program=jacobi_baseline\n";
    std::cout << "n=" << n << "\n";
    std::cout << "steps=" << steps << "\n";
    std::cout << "seconds=" << seconds << "\n";
    std::cout << "checksum=" << sum << "\n";

    return std::isfinite(sum) ? 0 : 1;
}

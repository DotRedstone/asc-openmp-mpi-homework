#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <random>
#include <string>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

std::vector<int> make_data(std::size_t n, std::uint32_t seed) {
    std::mt19937 rng(seed);
    std::uniform_int_distribution<int> dist(-1000000000, 1000000000);
    std::vector<int> a(n);
    for (std::size_t i = 0; i < n; ++i) {
        a[i] = dist(rng);
    }
    return a;
}

std::uint64_t checksum(const std::vector<int>& a) {
    std::uint64_t h = 1469598103934665603ull;
    for (int x : a) {
        std::uint64_t v = static_cast<std::uint64_t>(static_cast<std::int64_t>(x));
        h ^= v + 0x9e3779b97f4a7c15ull + (h << 6) + (h >> 2);
        h *= 1099511628211ull;
    }
    return h;
}

std::uint64_t multiset_fingerprint(const std::vector<int>& a) {
    std::uint64_t sum = 0;
    std::uint64_t xors = 0;
    for (int x : a) {
        std::uint64_t v = static_cast<std::uint64_t>(static_cast<std::int64_t>(x));
        std::uint64_t mixed = v * 0x9e3779b185ebca87ull + 0xbf58476d1ce4e5b9ull;
        sum += mixed;
        xors ^= mixed;
    }
    return sum ^ (xors + 0x94d049bb133111ebull);
}

void merge_range(std::vector<int>& a, std::vector<int>& tmp, std::size_t l, std::size_t m, std::size_t r) {
    std::size_t i = l;
    std::size_t j = m;
    std::size_t k = l;
    while (i < m && j < r) {
        tmp[k++] = (a[i] <= a[j]) ? a[i++] : a[j++];
    }
    while (i < m) tmp[k++] = a[i++];
    while (j < r) tmp[k++] = a[j++];
    for (std::size_t p = l; p < r; ++p) {
        a[p] = tmp[p];
    }
}

void merge_sort(std::vector<int>& a, std::vector<int>& tmp, std::size_t l, std::size_t r) {
    if (r - l <= 1) return;
    std::size_t m = l + (r - l) / 2;
    merge_sort(a, tmp, l, m);
    merge_sort(a, tmp, m, r);
    merge_range(a, tmp, l, m, r);
}

}  // namespace

int main(int argc, char** argv) {
    std::size_t n = 1000000;
    std::uint32_t seed = 2026;

    if (argc >= 2) n = static_cast<std::size_t>(std::stoull(argv[1]));
    if (argc >= 3) seed = static_cast<std::uint32_t>(std::stoul(argv[2]));

    std::vector<int> a = make_data(n, seed);
    std::uint64_t before = multiset_fingerprint(a);
    std::vector<int> tmp(a.size());

    auto start = Clock::now();
    merge_sort(a, tmp, 0, a.size());
    auto finish = Clock::now();

    double seconds = std::chrono::duration<double>(finish - start).count();
    bool sorted = std::is_sorted(a.begin(), a.end());
    bool same_values = (before == multiset_fingerprint(a));

    std::cout << "program=merge_sort_baseline\n";
    std::cout << "n=" << n << "\n";
    std::cout << "seed=" << seed << "\n";
    std::cout << "seconds=" << seconds << "\n";
    std::cout << "sorted=" << (sorted ? "OK" : "FAIL") << "\n";
    std::cout << "checksum=" << (same_values ? "OK" : "FAIL") << "\n";
    std::cout << "result_hash=" << checksum(a) << "\n";

    return (sorted && same_values) ? 0 : 1;
}

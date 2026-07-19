CXX ?= g++
CXXFLAGS ?= -O2 -std=c++17 -Wall -Wextra -pedantic
OMPFLAGS ?= -fopenmp

BUILD_DIR := build
SRC_DIR := src

.PHONY: all clean run-baseline run-small

all: \
	$(BUILD_DIR)/merge_sort_baseline \
	$(BUILD_DIR)/merge_sort_omp \
	$(BUILD_DIR)/jacobi_baseline \
	$(BUILD_DIR)/jacobi_omp

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/merge_sort_baseline: $(SRC_DIR)/merge_sort_baseline.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@

$(BUILD_DIR)/merge_sort_omp: $(SRC_DIR)/merge_sort_omp.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) $< -o $@

$(BUILD_DIR)/jacobi_baseline: $(SRC_DIR)/jacobi_baseline.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@

$(BUILD_DIR)/jacobi_omp: $(SRC_DIR)/jacobi_omp.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) $< -o $@

run-baseline: all
	bash scripts/run_baseline.sh

run-small: all
	./$(BUILD_DIR)/merge_sort_baseline 100000 2026
	OMP_NUM_THREADS=4 ./$(BUILD_DIR)/merge_sort_omp 100000 2026
	./$(BUILD_DIR)/jacobi_baseline 512 500
	OMP_NUM_THREADS=4 ./$(BUILD_DIR)/jacobi_omp 512 500

clean:
	rm -rf $(BUILD_DIR)

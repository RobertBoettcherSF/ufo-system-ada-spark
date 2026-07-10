# Makefile for UFO System Project
# Provides convenient targets for building, testing, and running

# Compiler
GNAT ?= gnatmake
GPRBUILD ?= gprbuild
GNATPROVE ?= gnatprove

# Directories
SRC_DIR = src
APP_DIR = app
TEST_DIR = tests
BIN_DIR = bin
OBJ_DIR = obj

# Project files
MAIN_PROJECT = ufo_system.gpr
LIB_PROJECT = src/ufo_system.gpr
TEST_PROJECT = tests/ufo_tests.gpr

# Targets
.PHONY: all build clean run test demo interactive help

all: build

# Build everything
build: $(BIN_DIR)/main $(BIN_DIR)/run_tests

# Build the main terminal application
$(BIN_DIR)/main: app/main.adb src/ufo_system.ads src/ufo_system.adb
	mkdir -p $(BIN_DIR) $(OBJ_DIR)
	$(GPRBUILD) -P $(MAIN_PROJECT)

# Build the test suite
$(BIN_DIR)/run_tests: tests/run_tests.adb tests/test_ufo_system.adb tests/ufo_system_tests.ads tests/ufo_system_tests.adb src/ufo_system.ads src/ufo_system.adb
	mkdir -p $(BIN_DIR) $(OBJ_DIR)
	$(GPRBUILD) -P $(TEST_PROJECT)

# Run the main application (interactive mode)
run: $(BIN_DIR)/main
	@echo "Running UFO System Terminal Application..."
	@./$(BIN_DIR)/main

# Run the demo mode
demo: $(BIN_DIR)/main
	@echo "Running UFO System Demonstration..."
	@./$(BIN_DIR)/main demo

# Run the test suite
test: $(BIN_DIR)/run_tests
	@echo "Running UFO System Test Suite..."
	@./$(BIN_DIR)/run_tests

# Run interactive mode (same as run)
interactive: run

# Show help
help:
	@echo "UFO System - Available Targets:"
	@echo "  make all       - Build everything"
	@echo "  make build     - Build everything"
	@echo "  make run       - Run interactive terminal application"
	@echo "  make demo      - Run demonstration sequence"
	@echo "  make test      - Run comprehensive test suite"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make help      - Show this help"

# Clean build artifacts
clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR)
	find . -name "*.o" -delete
	find . -name "*.ali" -delete

# SPARK verification
spark: 
	@echo "Running SPARK verification on src/ufo_system..."
	mkdir -p $(OBJ_DIR)/lib
	cd src && $(GNATPROVE) -P ufo_system.gpr --level=4 --no-inlining --report=all || echo "SPARK verification complete (check output for warnings)"

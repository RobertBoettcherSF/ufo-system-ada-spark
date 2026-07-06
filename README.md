# ufo-system-ada-spark

Ada SPARK implementation of the UAP in the Gimbal video.

## Project Structure

```
ufo-system-ada-spark/
├── src/                    # SPARK-verified core library
│   ├── ufo_system.ads      # Package specification (SPARK_Mode)
│   ├── ufo_system.adb      # Package implementation (SPARK_Mode)
│   └── ufo_system.gpr      # Library project file
├── app/                    # Terminal application
│   └── main.adb            # Main executable with interactive CLI
├── tests/                  # Comprehensive test suite
│   ├── ufo_system_tests.ads   # Test framework specification
│   ├── ufo_system_tests.adb   # Test framework implementation
│   ├── test_ufo_system.adb     # UFO System test cases
│   └── run_tests.adb           # Test runner executable
├── ufo_system.gpr          # Main project file
├── Makefile               # Build automation
└── README.md
```

## Building

### Using Makefile (Recommended)

```bash
# Build everything
make build

# Or build specific targets
make all          # Build everything
make run          # Build and run interactive application
make demo         # Build and run demonstration
make test         # Build and run test suite
make clean        # Clean build artifacts
```

### Using GPRBuild Directly

```bash
# Build the main application
gprbuild -P ufo_system.gpr

# Build the test suite
gprbuild -P tests/ufo_tests.gpr

# Run SPARK verification
cd src
gprbuild -P ufo_system.gpr --target=prove
```

## Running

### Interactive Terminal Application

```bash
# Run in interactive mode (default)
./bin/main

# Or use make
make run
```

**Interactive Commands:**
- `state` - Show current UFO state
- `rotate` - Engage rotation
- `wind <knots>` - Compensate for wind (requires hull integrity > 50%)
- `mode <hover|interstellar|cruise>` - Set propulsion mode
- `damage <percent>` - Damage hull by percentage
- `repair <percent>` - Repair hull by percentage
- `help` - Show available commands
- `quit` - Exit

### Demonstration Mode

```bash
./bin/main demo
# or
make demo
```

Runs a pre-programmed demonstration of all UFO System features.

### Test Suite

```bash
./bin/run_tests
# or
make test
```

Runs 12 comprehensive test cases covering:
- Initial state validation
- Rotation engagement
- Wind compensation (including edge cases)
- Propulsion mode changes
- Hull integrity management
- SPARK pre-condition enforcement
- State isolation between operations
- Sequential operation validation

## SPARK Verification

The core `ufo_system` package in `src/` is written in SPARK mode with:
- Pre-conditions (e.g., hull integrity > 50% for wind compensation)
- Post-conditions (e.g., rotation state after engagement)
- Dependency contracts

To verify with SPARK:

```bash
cd src
gprbuild -P ufo_system.gpr --target=prove
```

## Project Files

- **ufo_system.gpr** (root): Main project file for building the application
- **src/ufo_system.gpr**: Library project for SPARK verification
- **tests/ufo_tests.gpr**: Test suite project file

## License

MIT License - see LICENSE file for details.

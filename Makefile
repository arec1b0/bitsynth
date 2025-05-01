# Makefile for BitSynth project
# Provides a unified build system for all components

# Define the default target
.PHONY: all clean synth tracker tools

all: synth tracker tools

# Build main synthesizer
synth:
	@echo "Building BitSynth synthesizer..."
	@cd build && ./build.sh

# Build tracker interface
tracker:
	@echo "Building BitSynth tracker..."
	@chmod +x tracker/build_tracker.sh
	@cd tracker && ./build_tracker.sh

# Build utility tools
tools:
	@echo "Building utility tools..."
	@gcc -o output/note_calc tools/note_calc.c -lm
	@echo "Tools built successfully"

# Generate frequency tables from note calculator
tables: tools
	@echo "Generating frequency tables..."
	@output/note_calc > docs/frequency_tables.txt
	@echo "Tables generated"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f output/*.com output/note_calc
	@echo "Clean complete"

# Run the synthesizer in DOSBox (if available)
run:
	@if command -v dosbox >/dev/null 2>&1; then \
		echo "Running BitSynth in DOSBox..."; \
		dosbox output/bitsynth.com; \
	else \
		echo "DOSBox not found. Please install it to run BitSynth."; \
	fi

# Help target
help:
	@echo "BitSynth Build Targets:"
	@echo "  make all       - Build everything"
	@echo "  make synth     - Build just the synthesizer"
	@echo "  make tracker   - Build just the tracker"
	@echo "  make tools     - Build utility tools"
	@echo "  make tables    - Generate frequency tables" 
	@echo "  make clean     - Remove build artifacts"
	@echo "  make run       - Run in DOSBox (if installed)"
	@echo "  make help      - Show this help message"
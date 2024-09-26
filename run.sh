export PYTHONPATH=.:cairo-lang

cairo-run --program node.compiled.json --program_input node.input.json --layout recursive_with_poseidon --print_info --print_output
cairo-run --program aggregator.compiled.json --program_input aggregator.input.json --layout recursive_with_poseidon --print_info --print_output
cairo-run --program cairo_verifier.compiled.json --program_input cairo_verifier.input.json --layout recursive_with_poseidon --print_info --print_output
cairo-run --program applicative_bootloader.compiled.json --program_input applicative_bootloader.input.json --layout recursive_with_poseidon --print_info --print_output

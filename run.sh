export PYTHONPATH=.

cairo-run --program node.compiled.json --program_input node.input.json --layout recursive_with_poseidon --print_info --print_output
cairo-run --program aggregator.compiled.json --program_input aggregator.input.json --layout recursive_with_poseidon --print_info --print_output
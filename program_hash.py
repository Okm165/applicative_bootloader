import json
import sys
from starkware.cairo.lang.vm.crypto import poseidon_hash_many
from starkware.cairo.lang.compiler.program import Program

def fetch_compiled_program(compiled_program_file):
    program = Program.Schema().load(json.load(compiled_program_file))
    return program

if __name__ == "__main__":
    with open(sys.argv[1], 'r') as file:
        program = fetch_compiled_program(file)
        program_hash = poseidon_hash_many(program.data)
    print(program_hash)

# python program_hash.py <program.compiled.json path>
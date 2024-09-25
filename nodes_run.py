import os
import json
import tempfile

from objects import NodeClaim
from utils import cairo_run, stone_prove

# Paths for required files
LAYOUT = "recursive_with_poseidon"
NODE_PROGRAM = "node.compiled.json"
NODE1_PROGRAM_INPUT_FILE = "node1.input.json"
NODE2_PROGRAM_INPUT_FILE = "node2.input.json"
AGGREGATOR_PROGRAM = "aggregator.compiled.json"
AGGREGATOR_PROGRAM_INPUT_FILE = "aggregator.input.json"


def main():
    with tempfile.TemporaryDirectory() as tmpdir:
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=NODE_PROGRAM,
            program_input=NODE1_PROGRAM_INPUT_FILE,
        )

        stone_prove(tmpdir=tmpdir, out_file="./proofs/node1.proof.json")

    with tempfile.TemporaryDirectory() as tmpdir:
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=NODE_PROGRAM,
            program_input=NODE2_PROGRAM_INPUT_FILE,
        )

        stone_prove(tmpdir=tmpdir, out_file="./proofs/node2.proof.json")


if __name__ == "__main__":
    main()

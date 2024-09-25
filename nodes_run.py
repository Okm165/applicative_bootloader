import os
import json
import tempfile

from utils import cairo_run, stone_prove

# Paths for required files
LAYOUT = "recursive_with_poseidon"
NODE_PROGRAM = "node.compiled.json"
NODE_PROGRAM_INPUT_FILE = "node.input.json"
AGGREGATOR_PROGRAM = "aggregator.compiled.json"
AGGREGATOR_PROGRAM_INPUT_FILE = "aggregator.input.json"


def main():
    # Open and load the input JSON file
    with open(NODE_PROGRAM_INPUT_FILE, "r") as file:
        node_input_data = json.load(file)

    with tempfile.TemporaryDirectory() as tmpdir:
        # Modify node_input_json
        node_input_data["fibonacci_claim"]["a_start"] = 1
        node_input_data["fibonacci_claim"]["b_start"] = 1
        node_input_data["fibonacci_claim"]["n"] = 10

        node_input_file = os.path.join(tmpdir, NODE_PROGRAM_INPUT_FILE)
        with open(node_input_file, "w+") as file:
            file.write(json.dumps(node_input_data))
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=NODE_PROGRAM,
            program_input=node_input_file,
        )

        stone_prove(tmpdir=tmpdir, out_file="./proofs/node1.proof.json")

    with tempfile.TemporaryDirectory() as tmpdir:
        # Modify node_input_json
        node_input_data["fibonacci_claim"]["a_start"] = 89
        node_input_data["fibonacci_claim"]["b_start"] = 144
        node_input_data["fibonacci_claim"]["n"] = 10

        node_input_file = os.path.join(tmpdir, NODE_PROGRAM_INPUT_FILE)
        with open(node_input_file, "w+") as file:
            file.write(json.dumps(node_input_data))
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=NODE_PROGRAM,
            program_input=node_input_file,
        )

        stone_prove(tmpdir=tmpdir, out_file="./proofs/node2.proof.json")


if __name__ == "__main__":
    main()

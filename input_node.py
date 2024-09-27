import os
import json
from objects import NodeClaim

INPUT_FOLDER = "inputs"
NODE1_PROGRAM_INPUT_FILE = "node1.input.json"
NODE2_PROGRAM_INPUT_FILE = "node2.input.json"

with open(os.path.join(INPUT_FOLDER, NODE1_PROGRAM_INPUT_FILE), "w") as f:
    f.write(json.dumps(NodeClaim.Schema().dump(NodeClaim(1, 1, 10))))

with open(os.path.join(INPUT_FOLDER, NODE2_PROGRAM_INPUT_FILE), "w") as f:
    f.write(json.dumps(NodeClaim.Schema().dump(NodeClaim(89, 144, 10))))

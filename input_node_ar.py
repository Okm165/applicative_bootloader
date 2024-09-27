import os
import json
from objects import ApplicativeResult, NodeResult

INPUT_FOLDER = "inputs"
NODE1_AR_PROGRAM_INPUT_FILE = "node1_ar.input.json"
NODE2_AR_PROGRAM_INPUT_FILE = "node2_ar.input.json"

with open(os.path.join(INPUT_FOLDER, NODE1_AR_PROGRAM_INPUT_FILE), "w") as f:
    f.write(
        json.dumps(
            ApplicativeResult.Schema().dump(
                ApplicativeResult(
                    path_hash=0,
                    node_result=NodeResult(
                        a_start=1, b_start=1, n=10, a_end=89, b_end=144
                    ),
                )
            )
        )
    )

with open(os.path.join(INPUT_FOLDER, NODE2_AR_PROGRAM_INPUT_FILE), "w") as f:
    f.write(
        json.dumps(
            ApplicativeResult.Schema().dump(
                ApplicativeResult(
                    path_hash=0,
                    node_result=NodeResult(
                        a_start=89, b_start=144, n=10, a_end=10946, b_end=17711
                    ),
                )
            )
        )
    )

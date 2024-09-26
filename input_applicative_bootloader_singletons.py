import os
import json
from objects import ApplicativeBootloaderInput
from starkware.cairo.bootloaders.simple_bootloader.objects import (
    RunProgramTask,
    Program,
)

INPUT_FOLDER = "inputs"
PROOF_FOLDER = "proofs"
AGGREGATOR_PROGRAM = "aggregator.compiled.json"
VERIFIER_PROGRAM = "cairo_verifier.compiled.json"
NODE1_PROOF_FILE = "node1.proof.json"
NODE2_PROOF_FILE = "node2.proof.json"
NODE1_AR_PROGRAM_INPUT_FILE = "node1_ar.input.json"
NODE2_AR_PROGRAM_INPUT_FILE = "node2_ar.input.json"
APPLICTIVE_BOOTLOADER_SINGLETON1_PROGRAM_INPUT_FILE = (
    "applicative_bootloader_singleton1.input.json"
)
APPLICTIVE_BOOTLOADER_SINGLETON2_PROGRAM_INPUT_FILE = (
    "applicative_bootloader_singleton2.input.json"
)

with open(
    os.path.join(INPUT_FOLDER, APPLICTIVE_BOOTLOADER_SINGLETON1_PROGRAM_INPUT_FILE), "w"
) as f:
    f.write(
        json.dumps(
            ApplicativeBootloaderInput.Schema().dump(
                ApplicativeBootloaderInput(
                    aggregator_task=RunProgramTask(
                        program=Program.Schema().load(
                            json.loads(open(AGGREGATOR_PROGRAM, "r").read())
                        ),
                        program_input={
                            "nodes": [
                                json.loads(
                                    open(
                                        os.path.join(
                                            INPUT_FOLDER, NODE1_AR_PROGRAM_INPUT_FILE
                                        ),
                                        "r",
                                    ).read()
                                )
                            ]
                        },
                        use_poseidon=True,
                    ),
                    tasks=[
                        RunProgramTask(
                            program=Program.Schema().load(
                                json.loads(open(VERIFIER_PROGRAM, "r").read())
                            ),
                            program_input={
                                "proof": json.loads(
                                    open(
                                        os.path.join(PROOF_FOLDER, NODE1_PROOF_FILE),
                                        "r",
                                    ).read()
                                )
                            },
                            use_poseidon=True,
                        )
                    ],
                )
            )
        )
    )

with open(
    os.path.join(INPUT_FOLDER, APPLICTIVE_BOOTLOADER_SINGLETON2_PROGRAM_INPUT_FILE), "w"
) as f:
    f.write(
        json.dumps(
            ApplicativeBootloaderInput.Schema().dump(
                ApplicativeBootloaderInput(
                    aggregator_task=RunProgramTask(
                        program=Program.Schema().load(
                            json.loads(open(AGGREGATOR_PROGRAM, "r").read())
                        ),
                        program_input={
                            "nodes": [
                                json.loads(
                                    open(
                                        os.path.join(
                                            INPUT_FOLDER, NODE2_AR_PROGRAM_INPUT_FILE
                                        ),
                                        "r",
                                    ).read()
                                )
                            ]
                        },
                        use_poseidon=True,
                    ),
                    tasks=[
                        RunProgramTask(
                            program=Program.Schema().load(
                                json.loads(open(VERIFIER_PROGRAM, "r").read())
                            ),
                            program_input={
                                "proof": json.loads(
                                    open(
                                        os.path.join(PROOF_FOLDER, NODE2_PROOF_FILE),
                                        "r",
                                    ).read()
                                )
                            },
                            use_poseidon=True,
                        )
                    ],
                )
            )
        )
    )

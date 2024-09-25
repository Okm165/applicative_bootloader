import os
import math
import json
import logging
import subprocess

# Paths for required files
PARAMETER_FILE = "cpu_air_params.json"
PROVER_CONFIG_FILE = "cpu_air_prover_config.json"
NODE_PROGRAM = "node.compiled.json"
NODE_PROGRAM_INPUT_FILE_TEMPLATE = "node.input.json"
AGGREGATOR_PROGRAM = "aggregator.compiled.json"
AGGREGATOR_PROGRAM_INPUT_FILE_TEMPLATE = "aggregator.input.json"


def run_command(command: list):
    """Run a shell command and log the output or errors."""
    try:
        logging.info(f'Running command: {" ".join(command)}')
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed: {e}")
        raise


def extract_steps(public_input_file: str) -> int:
    """Extract 'n_steps' from the public input JSON file."""
    with open(public_input_file, "r") as f:
        public_input = json.load(f)
    return public_input.get("n_steps", 0)


def compute_fri_step_list(n_steps: int, config: dict) -> list:
    """Compute a new 'fri_step_list' based on the provided n_steps and config template."""
    n_steps_log = math.ceil(math.log(n_steps, 2))
    last_layer_degree_bound_log = math.ceil(
        math.log(config["stark"]["fri"]["last_layer_degree_bound"], 2)
    )
    sigma_fri_step_list = n_steps_log + 4 - last_layer_degree_bound_log

    q, r = divmod(sigma_fri_step_list, 4)
    return [0] + [4] * q + ([r] if r > 0 else [])


def update_parameter_file(parameter_file_path: str, tmpdir: str, n_steps: int) -> str:
    """Update the parameter file with a new 'fri_step_list' and save to a temporary file."""
    with open(parameter_file_path, "r") as f:
        config = json.load(f)

    # Update fri_step_list
    config["stark"]["fri"]["fri_step_list"] = compute_fri_step_list(n_steps, config)

    # Save updated config to a temporary file
    updated_file = os.path.join(tmpdir, "updated_cpu_air_params.json")
    with open(updated_file, "w") as f:
        json.dump(config, f, indent=4)

    logging.info(f"Updated parameter file saved: {updated_file}")
    return updated_file


def stone_prove(
    tmpdir: str,
    out_file: str,
):
    public_input_file = os.path.join(tmpdir, "public_input.json")
    private_input_file = os.path.join(tmpdir, "private_input.json")

    # Update parameter file with new fri_step_list
    n_steps = extract_steps(public_input_file)
    updated_parameter_file = update_parameter_file(PARAMETER_FILE, tmpdir, n_steps)

    # Run the prover
    run_command(
        [
            "cpu_air_prover",
            "--parameter_file",
            updated_parameter_file,
            "--prover_config_file",
            PROVER_CONFIG_FILE,
            "--public_input_file",
            public_input_file,
            "--private_input_file",
            private_input_file,
            "--out_file",
            out_file,
            "--generate_annotations",
        ]
    )


def cairo_run(
    tmpdir: str,
    layout: str,
    program: str,
    program_input: str,
):
    # Prepare files for the run step
    trace_file = os.path.join(tmpdir, "trace.bin")
    memory_file = os.path.join(tmpdir, "memory.bin")
    public_input_file = os.path.join(tmpdir, "public_input.json")
    private_input_file = os.path.join(tmpdir, "private_input.json")

    # Build and run the Cairo program command
    run_command(
        [
            "cairo-run",
            "--program",
            program,
            "--layout",
            layout,
            "--proof_mode",
            "--program_input",
            program_input,
            "--trace_file",
            trace_file,
            "--memory_file",
            memory_file,
            "--air_private_input",
            private_input_file,
            "--air_public_input",
            public_input_file,
            "--print_info",
            "--print_output",
        ]
    )

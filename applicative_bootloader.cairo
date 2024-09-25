%builtins output pedersen range_check bitwise poseidon

from starkware.cairo.bootloaders.simple_bootloader.run_simple_bootloader import (
    run_simple_bootloader,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin, PoseidonBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.cairo_verifier.objects import CairoVerifierOutput
from starkware.cairo.common.builtin_poseidon.poseidon import poseidon_hash_many
from objects import BootloaderOutput, bootloader_output_extract_output_hashes

func main{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    bitwise_ptr,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;

    let (__fp__, _) = get_fp_and_pc();

    // A pointer to the aggregator's task output.
    local aggregator_output_ptr: felt*;
    %{
        from objects import ApplicativeBootloaderInput
        from starkware.cairo.bootloaders.simple_bootloader.objects import SimpleBootloaderInput

        # Create a segment for the aggregator output.
        ids.aggregator_output_ptr = segments.add()

        # Load the applicative bootloader input and the aggregator task.
        applicative_bootloader_input = ApplicativeBootloaderInput.Schema().load(program_input)
        aggregator_task = applicative_bootloader_input.aggregator_task.load_task()

        # Create the simple bootloader input.
        simple_bootloader_input = SimpleBootloaderInput(
            tasks=[aggregator_task], fact_topologies_path=None, single_page=True
        )

        # Change output builtin state to a different segment in preparation for running the
        # aggregator task.
        applicative_output_builtin_state = output_builtin.get_state()
        output_builtin.new_state(base=ids.aggregator_output_ptr)
    %}

    // Save aggregator output start.
    let aggregator_output_start: felt* = aggregator_output_ptr;

    // Execute the simple bootloader with the aggregator task.
    run_simple_bootloader{output_ptr=aggregator_output_ptr}();
    let range_check_ptr = range_check_ptr;
    let bitwise_ptr = bitwise_ptr;
    let pedersen_ptr: HashBuiltin* = pedersen_ptr;
    let poseidon_ptr: PoseidonBuiltin* = poseidon_ptr;
    local aggregator_output_end: felt* = aggregator_output_ptr;

    // Check that exactly one task was executed.
    assert aggregator_output_start[0] = 1;

    // Extract the aggregator output size and program hash.
    let aggregator_output_length = aggregator_output_start[1];
    let aggregator_program_hash = aggregator_output_start[2];
    let aggregator_input_ptr = &aggregator_output_start[3];

    // Allocate a segment for the bootloader output.
    local bootloader_output_ptr: felt*;
    %{
        from starkware.cairo.bootloaders.simple_bootloader.objects import SimpleBootloaderInput

        # Save the aggregator's fact_topologies before running the bootloader.
        aggregator_fact_topologies = fact_topologies
        fact_topologies = []

        # Create a segment for the bootloader output.
        ids.bootloader_output_ptr = segments.add()

        # Create the bootloader input.
        simple_bootloader_input = SimpleBootloaderInput(
            tasks=applicative_bootloader_input.tasks, fact_topologies_path=None, single_page=True
        )

        # Change output builtin state to a different segment in preparation for running the
        # bootloader.
        output_builtin.new_state(base=ids.bootloader_output_ptr)
    %}

    // Save the bootloader output start.
    let bootloader_output_start = bootloader_output_ptr;

    // Execute the bootloader.
    run_simple_bootloader{output_ptr=bootloader_output_ptr}();
    let range_check_ptr = range_check_ptr;
    let bitwise_ptr = bitwise_ptr;
    let pedersen_ptr: HashBuiltin* = pedersen_ptr;
    let poseidon_ptr: PoseidonBuiltin* = poseidon_ptr;
    local bootloader_output_end: felt* = bootloader_output_ptr;

    if (bootloader_output_start[0] == 1) {
        // If one cairo verifier is ran this means terminal child so assert child program to node program hash
    }

    if (bootloader_output_start[0] == 2) {
        // If two cairo verifiers are ran this means tree node so applicative_bootloader program hash should be asserted
    }

    if (bootloader_output_start[0] != 1 and bootloader_output_start[0] != 2) {
        // unsupported variant for now
        assert 1 = 0;
    }

    let bootloader_output_length = bootloader_output_end - bootloader_output_start - 1;
    let nodes_len = bootloader_output_length / BootloaderOutput.SIZE;

    // Assert that the bootloader ran cairo0 verifiers.
    // TODO assert verifier program hash

    // Assert that the bootloader output agrees with the aggregator input.
    // calc poseidon hash of this output = poseidon([poseidon(ApplicativeResult) -- this part is calculated by every cairo0 verifier run this is output_hash -- omfg this connects so well])
    let (nodes_extracted: felt*) = alloc();
    bootloader_output_extract_output_hashes(
        list=cast(&bootloader_output_start[1], BootloaderOutput*),
        len=nodes_len,
        output=nodes_extracted,
    );
    let (input_hash: felt) = poseidon_hash_many(n=nodes_len, elements=nodes_extracted);

    // Check if aggregator program was ran on correct inputs
    // checking guessed the inputs of the aggregator program
    assert aggregator_input_ptr[0] = input_hash;

    %{
        # Restore the output builtin state.
        output_builtin.set_state(applicative_output_builtin_state)
    %}

    // Output the aggregated output.
    let aggregated_output_ptr = aggregator_input_ptr + 1;
    let aggregated_output_length = aggregator_output_end - aggregated_output_ptr;
    memcpy(dst=output_ptr, src=aggregated_output_ptr, len=aggregated_output_length);
    let output_ptr = output_ptr + aggregated_output_length;

    return ();
}

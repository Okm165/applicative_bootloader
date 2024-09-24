from starkware.cairo.cairo_verifier.objects import CairoVerifierOutput

struct NodeClaim {
    a_start: felt,
    b_start: felt,
    n: felt,
}

struct NodeResult {
    a_start: felt,
    b_start: felt,
    n: felt,
    a_end: felt,
    b_end: felt,
}

struct ApplicativeResult {
    aggregator_hash: felt,
    applicative_bootloader_hash: felt,
    node_result: NodeResult,
}

struct BootloaderOutput {
    program_hash: felt,
    program_output: CairoVerifierOutput,
}

func bootloader_output_extract_output_hashes(list: BootloaderOutput*, len: felt, output: felt*) {
    if (len == 0) {
        return ();
    }

    // extract only output_hash of node
    assert output[0] = list[0].program_output.output_hash;

    return bootloader_output_extract_output_hashes(
        list=&list[1], len=len - 1, output=&output[1]
    );
}

func applicative_results_calculate_hashes(list: ApplicativeResult*, len: felt, output: felt*) {
    if (list == 0) {
        return ();
    }

    assert output[0] = poseidon_hash_many(n=ApplicativeResult.SIZE, elements=list);

    return applicative_results_calculate_hashes(
        list=&list[1], len=len - 1, output=&output[1]
    );
}

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import PoseidonBuiltin
from starkware.cairo.cairo_verifier.objects import CairoVerifierOutput
from starkware.cairo.common.builtin_poseidon.poseidon import poseidon_hash_many

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
    node_result: NodeResult*,
}

func applicative_result_serialize(obj: ApplicativeResult*) -> felt* {
    let (serialized: felt*) = alloc();

    assert serialized[0] = obj.aggregator_hash;
    assert serialized[1] = obj.applicative_bootloader_hash;
    assert serialized[2] = obj.node_result.a_start;
    assert serialized[3] = obj.node_result.b_start;
    assert serialized[4] = obj.node_result.n;
    assert serialized[5] = obj.node_result.a_end;
    assert serialized[6] = obj.node_result.b_end;

    return serialized;
}

struct BootloaderOutput {
    output_length: felt,
    program_hash: felt,
    program_output: CairoVerifierOutput,
}

func bootloader_output_extract_output_hashes(list: BootloaderOutput*, len: felt, output: felt*) {
    if (len == 0) {
        return ();
    }

    // extract only output_hash of node
    assert output[0] = list[0].program_output.output_hash;
    return bootloader_output_extract_output_hashes(list=&list[1], len=len - 1, output=&output[1]);
}

func applicative_results_calculate_hashes{poseidon_ptr: PoseidonBuiltin*}(
    list: ApplicativeResult*, len: felt, output: felt*
) {
    if (len == 0) {
        return ();
    }

    let (hash) = poseidon_hash_many(
        n=ApplicativeResult.SIZE + NodeResult.SIZE - 1,
        elements=applicative_result_serialize(obj=list),
    );
    assert output[0] = hash;
    return applicative_results_calculate_hashes(list=&list[1], len=len - 1, output=&output[1]);
}

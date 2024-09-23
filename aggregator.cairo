%builtins output pedersen range_check bitwise poseidon

from objects import ApplicativeNodeResult, NodeResult
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.cairo_builtins import PoseidonBuiltin
from starkware.cairo.common.builtin_poseidon.poseidon import poseidon_hash_many

func main{output_ptr: felt*, pedersen_ptr: felt*, range_check_ptr: felt*, bitwise_ptr: felt*, poseidon_ptr: PoseidonBuiltin*}() {
    alloc_locals;

    let (__fp__, _) = get_fp_and_pc();

    local node_left_applicative_result: ApplicativeNodeResult*;
    local node_right_applicative_result: ApplicativeNodeResult*;

    %{
        from objects import AggregatorClaim

        aggregator_claim = AggregatorClaim.Schema().load(program_input['aggregator_claim'])

        ids.node_left_applicative_result = segments.gen_arg(vars(aggregator_claim.node_left).values())
        ids.node_right_applicative_result = segments.gen_arg(vars(aggregator_claim.node_right).values())
    %}

    // Ensure continuity
    assert node_left_applicative_result.node_result.a_end = node_right_applicative_result.node_result.a_start;
    assert node_left_applicative_result.node_result.b_end = node_right_applicative_result.node_result.b_start;
    assert node_left_applicative_result.aggregator_hash = node_right_applicative_result.aggregator_hash;

    // Compute the aggregated output.
    local applicative_result: ApplicativeNodeResult = ApplicativeNodeResult (
        aggregator_hash=node_left_applicative_result.aggregator_hash,
        node_result=NodeResult (
            a_start=node_left_applicative_result.node_result.a_start,
            b_start=node_left_applicative_result.node_result.b_start,
            n=node_left_applicative_result.node_result.n + node_right_applicative_result.node_result.n,
            a_end=node_right_applicative_result.node_result.a_end,
            b_end=node_right_applicative_result.node_result.b_end,
        )
    );

    // This represents the "input" of the aggregator, whose correctness is later verified
    // by the bootloader by running the Cairo verifier.
    let (node_left_output_hash: felt) = poseidon_hash_many(n=ApplicativeNodeResult.SIZE, elements=node_left_applicative_result);
    let (node_right_output_hash: felt) = poseidon_hash_many(n=ApplicativeNodeResult.SIZE, elements=node_right_applicative_result);

    // Output the "inputs" to the aggregator.
    assert output_ptr[1] = node_left_output_hash;
    assert output_ptr[2] = node_right_output_hash;
    let output_ptr = output_ptr + 2;

    // Output the combined result. This represents the "output" of the aggregator.
    memcpy(
        dst=output_ptr,
        src=&applicative_result,
        len=ApplicativeNodeResult.SIZE,
    );

    let output_ptr = &output_ptr[ApplicativeNodeResult.SIZE];

    return ();
}
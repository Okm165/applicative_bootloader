%builtins output pedersen range_check bitwise poseidon

from objects import ApplicativeResult, NodeResult
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.cairo_builtins import PoseidonBuiltin
from starkware.cairo.common.builtin_poseidon.poseidon import poseidon_hash_many

func main{
    output_ptr: felt*,
    pedersen_ptr: felt*,
    range_check_ptr: felt*,
    bitwise_ptr: felt*,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;

    let (__fp__, _) = get_fp_and_pc();

    local nodes: ApplicativeResult*;
    local nodes_len: felt252;

    %{
        from objects import AggregatorClaim

        aggregator_claim = AggregatorClaim.Schema().load(program_input['aggregator_claim'])

        ids.nodes = segments.gen_arg([vars(node).values() for node in aggregator_claim.nodes])
        ids.nodes_len = len(aggregator_claim.nodes)
    %}

    local applicative_result: ApplicativeResult;

    if (nodes_len == 1) {
        let node = nodes[0];

        // Compose the aggregated output.
        applicative_result = ApplicativeResult(
            aggregator_hash=node.aggregator_hash,
            applicative_bootloader_hash=node.applicative_bootloader_hash,
            node_result=NodeResult(
                a_start=node.node_result.a_start,
                b_start=node.node_result.b_start,
                n=node.node_result.n,
                a_end=node.node_result.a_end,
                b_end=node.node_result.b_end,
                )
            );
    } else {
        let node_left = nodes[0];
        let node_right = nodes[1];

        // Ensure continuity
        assert node_left.node_result.a_end = node_right.node_result.a_start;
        assert node_left.node_result.b_end = node_right.node_result.b_start;
        assert node_left.aggregator_hash = node_right.aggregator_hash;
        assert node_left.applicative_bootloader_hash = node_right.applicative_bootloader_hash;

        // Compose the aggregated output.
        applicative_result = ApplicativeResult(
            aggregator_hash=node_left.aggregator_hash,
            applicative_bootloader_hash=node.applicative_bootloader_hash,
            node_result=NodeResult(
                a_start=node_left.node_result.a_start,
                b_start=node_left.node_result.b_start,
                n=node_left.node_result.n + node_right.node_result.n,
                a_end=node_right.node_result.a_end,
                b_end=node_right.node_result.b_end,
                )
            );
    }

    let (nodes_hashed: felt*) = alloc();
    hash_nodes(nodes=nodes, nodes_len=nodes_len, output=nodes_hashed);

    // This represents the "input" of the aggregator, whose correctness is later verified
    // by the bootloader by running the Cairo verifier.
    let (input_hash: felt) = poseidon_hash_many(n=nodes_len, elements=nodes_hashed);

    // Output the "inputs" to the aggregator.
    assert output_ptr[0] = input_hash;
    let output_ptr = output_ptr + 1;

    // Output the combined result. This represents the "output" of the aggregator.
    memcpy(dst=output_ptr, src=&applicative_result, len=ApplicativeResult.SIZE);

    let output_ptr = &output_ptr[ApplicativeResult.SIZE];

    return ();
}

func hash_nodes(nodes: ApplicativeResult*, nodes_len: felt, output: felt*) {
    if (nodes_len == 0) {
        return ();
    }

    let (node_hash: felt) = poseidon_hash_many(n=ApplicativeResult.SIZE, elements=nodes);
    assert output[0] = node_hash;

    return hash_nodes(nodes=&nodes[1], nodes_len=nodes_len - 1, output=&output[1]);
}

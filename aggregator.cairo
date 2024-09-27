%builtins output pedersen range_check bitwise poseidon

from objects import (
    ApplicativeResult,
    NodeResult,
    applicative_results_calculate_hashes,
    applicative_result_serialize,
)
from starkware.cairo.common.alloc import alloc
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

    local nodes_len;
    local nodes: ApplicativeResult*;  // input to aggregator
    let (applicative_result: ApplicativeResult*) = alloc();  // output of aggregator

    // Guess the inputs of the aggregator program
    // this is later checked for in applicative bootloader that this input comes from children in lower level of tree
    %{
        from objects import AggregatorClaim

        aggregator_claim = AggregatorClaim.Schema().load(program_input)

        ids.nodes_len = len(aggregator_claim.nodes)
        ids.nodes = segments.gen_arg([
            item 
            for node in aggregator_claim.nodes
            for item in [node.path_hash, segments.gen_arg(vars(node.node_result).values())]
        ])
    %}

    let node_left = nodes[0];
    let node_right = nodes[1];

    // Ensure continuity
    assert node_left.node_result.a_end = node_right.node_result.a_start;
    assert node_left.node_result.b_end = node_right.node_result.b_start;

    let (path_hash_buff: felt*) = alloc();
    assert path_hash_buff[0] = node_left.path_hash;  // child path_hash
    assert path_hash_buff[1] = node_right.path_hash;  // child path_hash

    let (path_hash: felt) = poseidon_hash_many(n=2, elements=path_hash_buff);

    local node_result: NodeResult = NodeResult(
        a_start=node_left.node_result.a_start,
        b_start=node_left.node_result.b_start,
        n=node_left.node_result.n + node_right.node_result.n,
        a_end=node_right.node_result.a_end,
        b_end=node_right.node_result.b_end,
    );

    // Compose the aggregated output.
    local result: ApplicativeResult = ApplicativeResult(
        path_hash=path_hash, node_result=&node_result
    );

    memcpy(dst=applicative_result, src=&result, len=ApplicativeResult.SIZE);

    // Not supported to merge more then 2 nodes for now, will impl generic solution later so arbitrary positove integer num of nodes can be merged

    let (hashed_results: felt*) = alloc();
    applicative_results_calculate_hashes(list=nodes, len=nodes_len, output=hashed_results);

    // This represents the "input" of the aggregator, whose correctness is later verified
    // by the simple_bootloader by running the Cairo verifiers.
    // cairo0 verifiers will calculate same value by aquireing outputs from verified nodes
    // later they will calculate poseidon hash of this output = poseidon([output_hash <=> poseidon(ApplicativeResult from verified node)])
    let (input_hash: felt) = poseidon_hash_many(n=nodes_len, elements=hashed_results);

    // Output the "inputs" hash of the aggregator.
    assert output_ptr[0] = input_hash;
    let output_ptr = &output_ptr[1];

    // Output the combined result. This represents the "output" of the aggregator.
    memcpy(
        dst=output_ptr,
        src=applicative_result_serialize(obj=applicative_result),
        len=ApplicativeResult.SIZE + NodeResult.SIZE - 1,
    );
    let output_ptr = &output_ptr[ApplicativeResult.SIZE + NodeResult.SIZE - 1];

    return ();
}

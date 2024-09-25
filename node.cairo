%builtins output pedersen range_check bitwise poseidon

from objects import NodeClaim, NodeResult, ApplicativeResult, applicative_result_serialize
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_fp_and_pc

func main{output_ptr: felt*, pedersen_ptr: felt*, range_check_ptr: felt*, bitwise_ptr: felt*, poseidon_ptr: felt*}() {
    alloc_locals;

    let (__fp__, _) = get_fp_and_pc();

    local fibonacci_claim: NodeClaim*;
    %{
        from objects import NodeClaim
        ids.fibonacci_claim = segments.gen_arg(vars(
            NodeClaim.Schema().load(program_input['fibonacci_claim'])
        ).values())
    %}

    let (a_end, b_end) = fib(fibonacci_claim.a_start, fibonacci_claim.b_start, fibonacci_claim.n);

    local node_result: NodeResult = NodeResult(
        a_start=fibonacci_claim.a_start,
        b_start=fibonacci_claim.b_start,
        n=fibonacci_claim.n,
        a_end=a_end,
        b_end=b_end,
    );

    local applicative_result: ApplicativeResult = ApplicativeResult(
        aggregator_hash=0,
        applicative_bootloader_hash=0,
        node_result=&node_result,
    );

    // Output the applicative result.
    memcpy(
        dst=output_ptr,
        src=applicative_result_serialize(obj=&applicative_result),
        len=ApplicativeResult.SIZE + NodeResult.SIZE - 1,
    );
    let output_ptr = &output_ptr[ApplicativeResult.SIZE + NodeResult.SIZE - 1];

    return ();
}

func fib(first_element: felt, second_element: felt, n: felt) -> (felt, felt) {
    if (n == 0) {
        return (first_element, second_element);
    }

    return fib(
        first_element=second_element, second_element=first_element + second_element, n=n - 1
    );
}

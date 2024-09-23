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

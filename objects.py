from typing import List
import marshmallow_dataclass
from starkware.starkware_utils.validated_dataclass import ValidatedMarshmallowDataclass
from starkware.starkware_utils.validated_dataclass import (
    ValidatedMarshmallowDataclass,
)


@marshmallow_dataclass.dataclass(frozen=True)
class NodeClaim(ValidatedMarshmallowDataclass):
    a_start: int
    b_start: int
    n: int


@marshmallow_dataclass.dataclass(frozen=True)
class NodeResult(ValidatedMarshmallowDataclass):
    a_start: int
    b_start: int
    n: int
    a_end: int
    b_end: int

@marshmallow_dataclass.dataclass(frozen=True)
class ApplicativeResult(ValidatedMarshmallowDataclass):
    aggregator_hash: int
    applicative_bootloader_hash: int
    node_result: NodeResult

@marshmallow_dataclass.dataclass(frozen=True)
class AggregatorClaim(ValidatedMarshmallowDataclass):
    nodes: List[ApplicativeResult]


@marshmallow_dataclass.dataclass(frozen=True)
class AggregatorResult(ValidatedMarshmallowDataclass):
    node_output_hashes: List[int]
    node_result: ApplicativeResult

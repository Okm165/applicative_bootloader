from typing import List
import marshmallow_dataclass
from dataclasses import field
import marshmallow.fields as mfields
from starkware.starkware_utils.validated_dataclass import ValidatedMarshmallowDataclass
from starkware.starkware_utils.marshmallow_dataclass_fields import additional_metadata
from starkware.cairo.bootloaders.simple_bootloader.objects import TaskSpec, TaskSchema


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
    nodes_hash: int
    node_result: ApplicativeResult


@marshmallow_dataclass.dataclass(frozen=True)
class ApplicativeBootloaderInput(ValidatedMarshmallowDataclass):
    aggregator_task: TaskSpec = field(
        metadata=additional_metadata(marshmallow_field=mfields.Nested(TaskSchema))
    )

    tasks: List[TaskSpec] = field(
        metadata=additional_metadata(
            marshmallow_field=mfields.List(mfields.Nested(TaskSchema))
        )
    )

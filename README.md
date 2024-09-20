# Applicative Bootloader

**Applicative Bootloader** is a Cairo0 program designed to aggregate and merge proofs in a tree-like structure. It performs two main tasks: verifying child proofs and applying merge operations on the outputs of child proofs. The process involves:

1. **Verification:** Verifying the child proofs and extracting their outputs.
2. **Merging:** Applying merging logic to the outputs, producing a final result from the Applicative Bootloader's run.

The trace of this run is then proven, allowing the data structure to continue building the next level.

---

### Applicative Bootloader Architecture

The bootloader operates in two stages:

1. **Proof Verification and Output Extraction:** A Cairo0 verifier multi-task bootloader verifies multiple proofs.
2. **Output Merging:** A single-task bootloader applies the output merging logic to the extracted outputs.

<p align="center">
  <img src=".github/assets/applicative_bootloader.svg" alt="Applicative Bootloader Structure" width="800"/>
</p>

---

### Use Case

The primary use case for the Applicative Bootloader is to merge multiple task proofs into a single proof that is scalable for an arbitrary number of tasks, optimizing public memory usage, preventing it from growing indefinitely as the complexity of the proof tree increases and applying custom aggregation logic defined externally.

<p align="center">
  <img src=".github/assets/proof_merging.svg" alt="Proof Merging" width="800"/>
</p>

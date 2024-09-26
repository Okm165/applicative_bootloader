import tempfile

from utils import cairo_run, stone_prove

# Paths for required files
LAYOUT = "recursive_with_poseidon"
APPLICATIVE_BOOTLOADER_PROGRAM = "applicative_bootloader.compiled.json"
APPLICATIVE_BOOTLOADER_PROGRAM_INPUT1_FILE = "inputs/applicative_bootloader_singleton1.input.json"
APPLICATIVE_BOOTLOADER_PROGRAM_INPUT2_FILE = "inputs/applicative_bootloader_singleton2.input.json"


def main():
    with tempfile.TemporaryDirectory() as tmpdir:
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=APPLICATIVE_BOOTLOADER_PROGRAM,
            program_input=APPLICATIVE_BOOTLOADER_PROGRAM_INPUT1_FILE,
        )

        stone_prove(tmpdir=tmpdir, out_file="proofs/applicative_bootloader_singleton1.proof.json")
    
    with tempfile.TemporaryDirectory() as tmpdir:
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=APPLICATIVE_BOOTLOADER_PROGRAM,
            program_input=APPLICATIVE_BOOTLOADER_PROGRAM_INPUT2_FILE,
        )

        stone_prove(tmpdir=tmpdir, out_file="proofs/applicative_bootloader_singleton2.proof.json")


if __name__ == "__main__":
    main()

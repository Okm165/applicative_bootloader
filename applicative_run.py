import tempfile

from utils import cairo_run, stone_prove

# Paths for required files
LAYOUT = "recursive_with_poseidon"
APPLICATIVE_BOOTLOADER_PROGRAM = "applicative_bootloader.compiled.json"
APPLICATIVE_BOOTLOADER_PROGRAM_INPUT_FILE = "applicative_bootloader.input.json"


def main():
    with tempfile.TemporaryDirectory() as tmpdir:
        cairo_run(
            tmpdir=tmpdir,
            layout=LAYOUT,
            program=APPLICATIVE_BOOTLOADER_PROGRAM,
            program_input=APPLICATIVE_BOOTLOADER_PROGRAM_INPUT_FILE,
        )

        stone_prove(tmpdir=tmpdir, out_file="./proofs/node3.proof.json")


if __name__ == "__main__":
    main()
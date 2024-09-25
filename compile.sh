cairo-compile --cairo_path=cairo-lang/src node.cairo --output node.compiled.json --no_debug_info --proof_mode
cairo-compile --cairo_path=cairo-lang/src aggregator.cairo --output aggregator.compiled.json --no_debug_info
cairo-compile --cairo_path=cairo-lang/src applicative_bootloader.cairo --output applicative_bootloader.compiled.json --no_debug_info --proof_mode
cairo-compile --cairo_path=cairo-lang/src cairo-lang/src/starkware/cairo/cairo_verifier/layouts/all_cairo/cairo_verifier.cairo --output cairo_verifier.compiled.json --no_debug_info

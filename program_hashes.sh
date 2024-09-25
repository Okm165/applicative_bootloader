#!/bin/bash

echo "Hash of node"
python program_hash.py node.compiled.json

echo "Hash of aggregator"
python program_hash.py aggregator.compiled.json

echo "Hash of applicative_bootloader"
python program_hash.py applicative_bootloader.compiled.json

echo "Hash of cairo_verifier"
python program_hash.py cairo_verifier.compiled.json
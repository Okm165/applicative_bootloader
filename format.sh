cairo-format -i aggregator.cairo
cairo-format -i applicative_bootloader.cairo 
cairo-format -i node.cairo
cairo-format -i objects.cairo
black objects.py program_hash.py utils.py applicative_run.py 
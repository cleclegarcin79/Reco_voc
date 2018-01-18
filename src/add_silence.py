#!/usr/bin/python3
import sys

if len(sys.argv) == 2:
    buffer = []
    for line in sys.stdin:
        buffer.append(line)

    with open(sys.argv[1], 'w') as f:
        for line in buffer:
            f.write(line)

        f.write("SILENCE         sil\n")


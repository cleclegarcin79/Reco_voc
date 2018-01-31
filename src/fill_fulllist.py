#!/usr/bin/python3
import sys

if len(sys.argv) == 2:
    phones = []
    with open(sys.argv[1], 'r') as f:
        for line in f:
            if line.strip() not in phones:
                phones.append(line.strip())

    for line in sys.stdin:
        if line.strip() not in phones:
            phones.append(line.strip())

    for line in phones:
        sys.stdout.write(line+"\n")


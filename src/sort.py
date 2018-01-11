#!/usr/bin/python3
import sys

buffer = []
for line in sys.stdin:
    if (len(line.split()) > 1):
        line = (line.split()[0].upper() + line[len(line.split()[0]):])
    buffer.append(line.strip())

buffer.sort()

for line in buffer:
    sys.stdout.write(line + "\n")

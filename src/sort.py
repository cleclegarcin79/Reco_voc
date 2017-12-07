#!/usr/bin/env python
import sys

buffer = []
for line in sys.stdin:
    buffer.append(line)

buffer.sort()

for line in buffer:
    sys.stdout.write(line)

#!/usr/bin/python3
import sys


for line in sys.stdin:
    if (line.strip() != 'sp'):
        sys.stdout.write(line)

sys.stdout.write("sil\n")
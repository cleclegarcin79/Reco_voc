#!/usr/bin/python3
import sys

sys.stdout.write("#!MLF!#\n")
count = 1
for line in sys.stdin:
    sys.stdout.write("\"*{:0>4d}.lab\"\n".format(count))
    for w in line.split()[1:]: # skip the number at the start
        sys.stdout.write(w + "\n")
    sys.stdout.write(".\n")
    count += 1

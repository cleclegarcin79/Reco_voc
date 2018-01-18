#!/usr/bin/python3
import sys

buffer = []

mark = False
found = False
for line in sys.stdin:
    sys.stdout.write(line)
    if mark:
        buffer.append(line)
        if(line.strip() == "<ENDHMM>"):
            mark = False
    if not found and line.strip() == "~h \"sil\"":
        found = True
        mark = True
    


sys.stdout.write("~h \"sp\"\n")
for line in buffer:
    sys.stdout.write(line)


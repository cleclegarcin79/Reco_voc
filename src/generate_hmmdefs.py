#!/usr/bin/python3
import sys

if(len(sys.argv) == 2):

    buffer = []
    tags = [x.strip() for x in open(sys.argv[1])]

    mark = False
    for line in sys.stdin:
        if not mark and line.strip() == "<BEGINHMM>":
            mark = True
        if mark:
            buffer.append(line)


    for tag in tags:
        sys.stdout.write("~h \"" + tag + "\"\n")
        for line in buffer:
            sys.stdout.write(line)
        sys.stdout.write("\n")


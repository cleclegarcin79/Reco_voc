#!/usr/bin/python3
import sys
import re

phones = set()
for line in sys.stdin:
    phones.add(line.strip())
    #if '+' in line or '-' in line:
    #    for phone in re.findall(r"[\w']+", line.strip()):
    #        phones.add(phone)

sys.stdout.write("CL ./var/triphones1\n")
for phone in phones:
    if phone != "sil" and phone != "sp":
        sys.stdout.write("TI T_{0} {{(*-{0}+*,{0}+*,*-{0}).transP}}\n".format(phone))
        
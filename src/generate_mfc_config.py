#!/usr/bin/python3
import sys
import glob

for file in glob.glob("./wave/*.wav"):
    sys.stdout.write(file + " " + (file.replace("/wave/","/train/").replace(".wav",".mfc")) + "\n")
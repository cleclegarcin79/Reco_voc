#!/usr/bin/python3
import sys
import glob

for file in glob.glob("./WAVE/*/*.wav"):
    sys.stdout.write(file + " " + (file.replace("/WAVE/","/mfc/").replace(".wav",".mfc")) + "\n")
#!/usr/bin/python3
import sys
import glob

if(len(sys.argv) == 3):
    for file in glob.glob("./WAVE/" + sys.argv[1] + "/*.wav"):
        sys.stdout.write((file.replace("/WAVE/","/mfc/").replace(".wav",".mfc")) + "\n")
elif(len(sys.argv) == 2):
    for file in glob.glob("./WAVE/" + sys.argv[1] + "/*.wav"):
        sys.stdout.write(file + " " + (file.replace("/WAVE/","/mfc/").replace(".wav",".mfc")) + "\n")
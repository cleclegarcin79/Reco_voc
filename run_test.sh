#!/bin/sh
cat ./prompt-testset.txt | ./src/conv2mlf.py > ./var/words_test.mlf

#./bin.linux/HVite -B -H ./HMM/hmm15/macros -H ./HMM/hmm15/hmmdefs -S ./var/test.scp -l '*' -i ./var/recout.mlf -w ./var/wdnet.txt -p 0.0 -s 5.0 ./var/dict.txt ./var/tiedlist 
./bin.linux/HVite -B -H ./HMM/hmm12/macros -H ./HMM/hmm12/hmmdefs -S ./var/test.scp -l '*' -i ./var/recout.mlf -w ./var/wdnet.txt -p 0.0 -s 5.0 ./var/dict.txt ./var/triphones1

./bin.linux/HResults -I ./var/words_test.mlf ./var/tiedlist ./var/recout.mlf
#!/bin/sh

if [ ! -d "log" ]; then
	mkdir log
fi
if [ ! -d "var" ]; then
	mkdir var
fi

if [ ! -d "mfc" ]; then
	mkdir mfc
	mkdir mfc/train
	mkdir mfc/test
fi

if [ ! -d "HMM" ]; then
	mkdir HMM
	mkdir HMM/hmm0
	mkdir HMM/hmm1
	mkdir HMM/hmm2
	mkdir HMM/hmm3
fi

chmod +x ./src/*.py
chmod +x ./bin.linux/*

#########################
#### Grammar Parsing ####
#########################

./bin.linux/HParse ./conf/gram.txt ./var/wdnet.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HParse'\n"
	exit $ERROR_CODE
else
	printf "wdnet.txt written to ./var\n"
fi

############################
#### Dictionary Parsing ####
############################

cat ./conf/fr.dict | ./src/sort.py > ./var/fr.sorted.dict

if [ $? != 0 ]; then
    printf "Error when sorting dictionary: './var/fr.dict'\n"
	exit $ERROR_CODE
else
	printf "sorted './var/fr.dict' to './var/fr.sorted.dict' \n"
fi

cat ./conf/words.txt | ./src/sort.py > ./var/words.sorted.txt

if [ $? != 0 ]; then
    printf "Error when sorting dictionary: './var/words.txt'\n"
	exit $ERROR_CODE
else
	printf "sorted './var/words.txt' to './var/words.sorted.txt' \n"
fi

./bin.linux/HDMan -m -w ./var/words.sorted.txt -n ./var/monophones1 -l ./log/dlog ./var/dict.txt ./var/fr.sorted.dict

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HDMan'\n"
	exit $ERROR_CODE
else
	printf "dict.txt written to ./var\n"
fi

cat ./var/monophones1 | ./src/create_monophones0.py > ./var/monophones0

if [ $? != 0 ]; then
    printf "Error when generating monophones0: './var/monophones0'\n"
	exit $ERROR_CODE
else
	printf "created './var/monophones0' \n"
fi

############################
#### Samples generation ####
############################

if [ ! -f "testprompts.txt" ]; then
	./bin.linux/HSGen -l -n 200 ./var/wdnet.txt ./var/dict.txt > testprompts.txt

	if [ $? != 0 ]; then
	    printf "Error when executing command: './bin.linux/HSGen'\n"
		exit $ERROR_CODE
	else
		printf "testprompts.txt written to ./\n"
	fi
fi

#######################
#### Parse prompts ####
#######################

cat ./testprompts.txt | ./src/conv2mlf.py > ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when parsing prompts: './testprompts.txt'\n"
	exit $ERROR_CODE
else
	printf "converted './testprompts.txt' to './var/words.mlf' \n"
fi

#########################
#### make MLF phones ####
#########################

./bin.linux/HLEd -l '*' -d ./var/dict.txt -i ./var/phones0.mlf ./conf/mkphones0.led ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HLEd'\n"
	exit $ERROR_CODE
else
	printf "phones0.mlf written to ./var\n"
fi

########################
#### convert to MFC ####
########################

./src/generate_mfc_config.py train > ./var/codetr_train.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/codetr_train.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/codetr_train.scp'\n"
fi

./src/generate_mfc_config.py test > ./var/codetr_test.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/codetr_test.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/codetr_test.scp'\n"
fi

./src/generate_mfc_config.py train partial > ./var/train.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/train.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/train.scp'\n"
fi

./src/generate_mfc_config.py test partial > ./var/test.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/test.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/test.scp'\n"
fi

./bin.linux/HCopy -T 1 -C ./conf/wave_config -S ./var/codetr_train.scp

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCopy'\n"
	exit $ERROR_CODE
else
	printf "parsed ./WAVE/train \n"
fi

./bin.linux/HCopy -T 1 -C ./conf/wave_config_test -S ./var/codetr_test.scp

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCopy'\n"
	exit $ERROR_CODE
else
	printf "parsed ./WAVE/test \n"
fi

#######################
#### HMM Trainning ####
#######################

./bin.linux/HCompV -C ./conf/HMM_config -f 0.01 -m -S ./var/train.scp -M ./HMM/hmm0 ./conf/HMM_proto

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCompV'\n"
	exit $ERROR_CODE
else
	printf "saved HMM to ./HMM/hmm0/HMM_proto\n"
fi

cat ./HMM/hmm0/vFloors | ./src/generate_macro.py > ./HMM/hmm0/macros

if [ $? != 0 ]; then
    printf "Error when generating: 'macros'\n"
	exit $ERROR_CODE
else
	printf "generated 'macros' \n"
fi

cat ./HMM/hmm0/HMM_proto | ./src/generate_hmmdefs.py ./var/monophones0 > ./HMM/hmm0/hmmdefs

if [ $? != 0 ]; then
    printf "Error when generating: 'hmmdefs'\n"
	exit $ERROR_CODE
else
	printf "generated 'hmmdefs' \n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm0/macros -H ./HMM/hmm0/hmmdefs -M ./HMM/hmm1 ./var/monophones0

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated monophones 1\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm1/macros -H ./HMM/hmm1/hmmdefs -M ./HMM/hmm2 ./var/monophones0

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated monophones 2\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm2/macros -H ./HMM/hmm2/hmmdefs -M ./HMM/hmm3 ./var/monophones0

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated monophones 3\n"
fi

############################
#### HMM silence fixing ####
############################

printf "Finished without errors!\n"
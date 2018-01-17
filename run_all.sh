#!/bin/sh

if [ ! -f "log" ]; then
	mkdir log
fi
if [ ! -f "var" ]; then
	mkdir var
fi

if [ ! -f "mfc" ]; then
	mkdir mfc
	mkdir mfc/train
	mkdir mfc/test
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

./src/generate_mfc_config.py > ./var/codetr.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/codetr.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/codetr.scp'\n"
fi

./bin.linux/HCopy -T 1 -C ./conf/config -S ./var/codetr.scp

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCopy'\n"
	exit $ERROR_CODE
else
	printf "parsed ./wav/* to ./train/*\n"
fi

printf "Finished without errors!\n"
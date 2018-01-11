#!/bin/sh

if [ ! -f "log" ]; then
	mkdir log
fi
if [ ! -f "var" ]; then
	mkdir var
fi

chmod +x *.sh
chmod +x ./src/*.py
chmod +x ./bin.linux/*

./parse_grammer.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi

./parse_dict.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi


if [ ! -f "testprompts.txt" ]; then
	./generate_samples.sh

	if [ $? != 0 ]; then
		exit $ERROR_CODE
	fi
fi

./parse_prompts.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi

./make_mlf_phone.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi

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

printf "Done!\n"
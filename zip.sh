#!/bin/bash
zipname="big-bum"
version=$(cat .version)
cd zip/
if [ $1 == "Linaro" ]; then
	cp ../boot-L-v"$version"-Linaro.img boot.img
	zip -q -r -9 "$zipname"-L-v"$version"-Linaro.zip *
	rm *.img
	mv *.zip ../
	echo "Linaro zip made"
fi
if [ $1 == "SM" ]; then
	cp ../boot-L-v"$version"-SM.img boot.img
	zip -q -r -9 "$zipname"-L-v"$version"-SM.zip *
	rm *.img
	mv *.zip ../
	echo "SM zip made"
fi

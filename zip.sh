#!/bin/bash
zipname="big-bum"
version=$(cat .version)
cd zip/
rm -f ../*.zip

for branch in L L-f2fs L-f2fs-all; do
	cp ../boot-"$branch"-v"$version".img boot.img
	zip -q -r -9 "$zipname"-"$branch"-v"$version".zip *
	mv *.zip ../
	rm *.img
	if [ -e ../"$zipname"-"$branch"-v"$version".zip ]; then
		echo "$branch zip made"
	fi
done

#!/bin/bash
zipname="big-bum"
version=$(cat .version)
cd zip/
rm -f ../*.zip

branch=mpd
	cp ../boot-"$branch"-v"$version".img boot.img
	zip -q -r -9 "$zipname"-"$branch"-v"$version".zip *
	mv *.zip ../
	rm *.img
	if [ -e ../"$zipname"-"$branch"-v"$version".zip ]; then
		echo "$branch zip made"
	fi

#CM
cd ../zip_cm
cp ../boot-mpd-v"$version".img boot.img
zip -q -r -9 "$zipname"-cm-"$branch"-v"$version".zip *
mv *.zip ../
rm *.img
if [ -e ../"$zipname"-cm-"$branch"-v"$version".zip ]; then
	echo "cm zip made"
fi

#!/bin/bash
zipname="big-bum"
version=$(cat .version)
cd zip/
cp ../boot-L-v"$version".img boot.img
zip -q -r -9 "$zipname"-L-v"$version".zip *
mv *.zip ../
rm *.img
if [ -e ../"$zipname"-L-v"$version".zip ]; then
	echo "zip made"
fi

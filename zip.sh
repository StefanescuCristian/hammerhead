#!/bin/bash
zipname="big-bum"
version=$(cat .version)
cd zip/
rm -f ../*.zip

#normal version
cp ../boot-v"$version".img boot.img
zip -r -9 "$zipname"-v"$version".zip *
mv *.zip ../
rm *.img

#f2fs
cp ../boot-f2fs-v"$version".img boot.img
zip -r -9 "$zipname"-f2fs-v"$version".zip *
mv *.zip ../
rm *.img

#f2fs-all
cp ../boot-f2fs-all-v"$version".img boot.img
zip -r -9 "$zipname"-f2fs-all-v"$version".zip *
mv *.zip ../
rm *.img

#CM
cd ../zip_cm
cp ../boot-v"$version".img boot.img
zip -r -9 "$zipname"-cm-v"$version".zip *
mv *.zip ../
rm *.img

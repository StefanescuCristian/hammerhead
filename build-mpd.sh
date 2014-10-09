#!/bin/bash

rm *.img
rm *.zip
	
make mrproper
make big-bum-mpd_defconfig

if [ $# -gt 0 ]; then
echo $1 > .version
fi
J=$(echo $(($(grep processor /proc/cpuinfo | wc -l) + 1)))
make -j"$J"

if [ -e arch/arm/boot/zImage-dtb ]; then
cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

version=$(cat ../hammerhead/.version)
branch=mpd
	git checkout $branch
	echo "making $branch ramdisk"
	./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
	echo "making $branch boot image"
	./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-"$branch"-v"$version".img
	rm -rf ramdisk.gz

rm -rf zImage*

cd ../hammerhead
fi

if [ -e "boot-"$branch"-v"$version".img" ]; then
	./zip-mpd.sh
	./private_push "boot-"$branch"-v"$version".img"
fi

rm arch/arm/boot/zImage*

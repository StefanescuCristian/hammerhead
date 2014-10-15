#!/bin/bash

rm *.img
rm *.zip
	
make mrproper
make big-bum_defconfig

if [ $# -gt 0 ]; then
echo $1 > .version
fi
J=$(echo $(($(grep processor /proc/cpuinfo | wc -l) + 1)))
STARTTIME=$(date +%s)
make -j"$J"

if [ -e arch/arm/boot/zImage-dtb ]; then
cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

version=$(cat ../hammerhead/.version)
for branch in ext4 f2fs f2fs-all; do
	git checkout $branch
	echo "making $branch ramdisk"
	./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
	echo "making $branch boot image"
	./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-"$branch"-v"$version".img
	rm -rf ramdisk.gz
done

rm -rf zImage*

cd ../hammerhead
fi
ENDTIME=$(date +%s)

if [ -e "boot-ext4-v"$version".img" ]; then
	./zip.sh
	../private_apps/private_push
fi

rm arch/arm/boot/zImage*
echo "It took $(($ENDTIME - $STARTTIME)) seconds to build"

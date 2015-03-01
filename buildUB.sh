#!/bin/bash
#Uber - https://github.com/UBERTC/uber-manifest && https://github.com/UBERTC/arm-eabi-4.9
export CROSS_COMPILE="ccache ../uber-arm-eabi-4.9/bin/arm-eabi-"
echo "UB" > .tc
rm *UB.img *UB.zip

make mrproper
make cyanogenmod_hammerhead_defconfig

if [ $# -gt 0 ]; then
echo $1 > .version
fi

make -j5

cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/
git checkout L-cm
version=$(cat ../hammerhead/.version)

./mkbootfs bootcm.img-ramdisk | gzip -9 > ramdisk.gz
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead androidboot.selinux=permissive user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-L-v"$version"-UB.img
rm -rf ramdisk.gz

rm -rf zImage*

cd ../hammerhead

rm arch/arm/boot/zImage*

if [ "$2" != "" ]; then
	./zip.sh UB
fi

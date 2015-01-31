#!/bin/bash
#SM - https://github.com/AuxXxilium/sm-arm-cortex_a15-eabi-4.9
CROSS_COMPILE="ccache ../sm-arm-cortex_a15-eabi-4.9/bin/arm-eabi-"

rm *SM.img *SM.zip

make mrproper
make big-bum_defconfig

if [ $# -gt 0 ]; then
	echo $1 > .version
fi

make -j5

cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

version=$(cat ../hammerhead/.version)

./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead androidboot.selinux=permissive user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-L-v"$version"-SM.img
rm -rf ramdisk.gz

rm -rf zImage*

cd ../hammerhead

rm arch/arm/boot/zImage*

if [ "$2" != "" ]; then
	./zip.sh SM
fi

#!/bin/bash
#Linaro with LTO support - https://github.com/SlimForce/arm-eabi-4.9-cortex-a15
export CROSS_COMPILE="ccache ../arm-eabi-4.9-cortex-a15/bin/arm-eabi-"
echo "LTO" > .tc
rm *.img

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
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1 mdss_mdp.panel=dsi androidboot.bootdevice=msm_sdcc.1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-L-v"$version"-CAF.img
rm -rf ramdisk.gz

rm -rf zImage*

cd ../hammerhead

rm arch/arm/boot/zImage*

if [ "$2" != "" ]; then
	./zip.sh Linaro
fi

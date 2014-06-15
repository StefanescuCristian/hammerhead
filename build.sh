#!/bin/bash
./commit.sh
make mrproper
make franco_defconfig

if [ $# -gt 0 ]; then
echo $1 > .version
fi

make -j4

cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

version=$(cat ../hammerhead/.version)
git checkout master
echo "making ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
echo "making normal boot image"
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-v"$version".img
rm -rf ramdisk.gz

git checkout f2fs
echo "making f2fs ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
echo "making f2fs boot image"
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-f2fs-v"$version".img
rm -rf ramdisk.gz

git checkout f2fs-all
echo "making f2fs-all ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
echo "making f2fs-all boot image"
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-f2fs-all-v"$version".img
rm -rf ramdisk.gz

rm -rf zImage*

./zip.sh

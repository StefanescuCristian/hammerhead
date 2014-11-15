make mrproper; make franco_defconfig; make -j5
cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/
cd ../ramdisk_hammerhead/
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot-"L"-v"$version".img
rm -rf ramdisk.gz
rm -rf zImage*
cd ../hammerhead
rm arch/arm/boot/zImage*


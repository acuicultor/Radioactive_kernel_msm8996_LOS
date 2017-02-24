#!/bin/bash
rm .version
make mrproper
make clean
# Kernel Details
VER="_V1.1.3_oneplus3-3T"
BASE_AK_VER="Radioactive"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=acuicultor
export KBUILD_BUILD_HOST=NuclearPowerPlant

#paths
KERNEL_DIR="/home/acuicultor/android/kernels/rebase/Radioactive_Kernel_LOS_OP3_3T"
ZIP_MOVE="${HOME}/android/releases"
ZIMAGE_DIR="/home/acuicultor/android/kernels/rebase/Radioactive_Kernel_LOS_OP3_3T/arch/arm64/boot"
MODULES_DIR="${HOME}/android/lazyflasher/modules"

#build info 
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE=${HOME}/Android/toolchains/ubernaro-aarch64-linux-android-4.9/bin/aarch64-linux-android-
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
DEFCONFIG="radioactive_defconfig"
make $DEFCONFIG
make $THREAD

#make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb ~/android/lazyflasher/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd ~/android/lazyflasher
make VERSION=$VER NAME=$BASE_AK_VER
cd $KERNEL_DIR

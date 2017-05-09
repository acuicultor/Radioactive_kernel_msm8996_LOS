#!/bin/bash
#########################################################################################################################
#########################################################################################################################
# Kernel Details
VER="V1.3.4_oneplus3-3T"
BASE_VER="Radioactive"

# Set build folder
BUILD_DIR="${HOME}/Releases"

BUILDER_NAME="acuicultor"
BUILD_HOST_NAME="NuclearPowerPlant"

# Set kernel source git link
KSOURCE_GIT="https://github.com/acuicultor/Radioactive_kernel_msm8996_LOS.git -b radioactive"

# Set kernel source folder
KERNEL_DIR="/home/acuicultor/android/kernels/Radioactive_kernel_msm8996_LOS"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot" # Only change on soc/arch change ->arm64-arm etc.

# Kernel Arch
KERNEL_ARCH="arm64"

# Set defconfig for the kernel
KERNEL_DEFCONFIG="radioactive_defconfig"

# Set kernel toolchain path
TOOLCHAIN_DIR="${HOME}/Android/toolchains/ubernaro-aarch64-linux-android-4.9/bin/aarch64-linux-android-"

# Set lazyflasher source git link
LSOURCE_GIT="https://github.com/acuicultor/lazyflasher.git -b radioactive"
LAZYFLASHER_DIR="$BUILD_DIR/lazyflasher" #No changes needed
MODULES_DIR="$LAZYFLASHER_DIR/modules" #No changes needed

# Set output folder
ZIP_MOVE="$BUILD_DIR/Releases"

# Builder script headline
HEADLINE_TXT="Advanced kernel builder script by acuicultor"

# Enable/Disable output folder cleanup dialog
OUTPUT_EMPTY_CHECK="1"

# Enable/Disable colors for the build
COLOR_TXT="0"

# Enable/Disable clear the history of the kernel source (ONLY ON SUCCESS on error not for debug)
CLEAR_ON_SUCCESS="1"
#########################################################################################################################
#########################################################################################################################




# Check if lazyflasher is present
folder1="$LAZYFLASHER_DIR/*.*"
if [ "$(ls -A $folder1)" ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;32mLazyflasher is present"
	tput sgr0
else
   	echo -e "\E[1;31mDownloading lazyflasher dependencie"
   	tput sgr0
   	git clone $LSOURCE_GIT $LAZYFLASHER_DIR
fi

# Check if kernel source is present
folder2="$KERNEL_DIR/*.*"
if [ "$(ls -A $folder2)" ]; then
   echo -e "\E[1;32mKernel source is present"
   tput sgr0
else
   echo -e "\E[1;31mDownloading kernel source"
   tput sgr0
   git clone $KSOURCE_GIT $KERNEL_DIR
fi

# Cleanup remains of last builds
cd $KERNEL_DIR # It's more safe to move first here. We don't want to clean any other git folder
git clean -d -f -x > /dev/null 2>&1
cd $LAZYFLASHER_DIR
git clean -d -f -x > /dev/null 2>&1
cd $KERNEL_DIR

# Empty output?
if [ $OUTPUT_EMPTY_CHECK == 1 ]; then
output1="$ZIP_MOVE/*.zip"
output2="$ZIP_MOVE/*.sha1"
if [ -e $output1 ] &&  [ -e $output2 ]; then # Both must be there otherwise they will be ignored
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mOutput folder contains older versions"
	echo -e ""
	read -p "Empty output folder? (y/n) " prompt
	tput sgr0
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
	rm $ZIP_MOVE/*.zip
	rm $ZIP_MOVE/*.sha1
	echo -e "\E[1;31mCleanup successful!"
	tput sgr0
else
	echo -e ""
fi
fi
fi

echo -e ""
echo -e ""
echo -e "\e[1;4m$HEADLINE_TXT"
echo -e ""
echo -e "" 
tput sgr0

if [ $COLOR_TXT == 1 ]; then
	echo -e "\e[43m"
	echo -e "\e[30m"
fi


# Vars
export ARCH=$KERNEL_ARCH
export SUBARCH=$KERNEL_ARCH
export KBUILD_BUILD_USER=$BUILDER_NAME
export KBUILD_BUILD_HOST=$BUILD_HOST_NAME

# Build info 
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE="$TOOLCHAIN_DIR"
AKBS_VER="$BASE_VER$VER"
export LOCALVERSION=~`echo $AKBS_VER`
export LOCALVERSION=~`echo $AKBS_VER`
DEFCONFIG="$KERNEL_DEFCONFIG"
make $DEFCONFIG
make $THREAD

# Make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb $LAZYFLASHER_DIR/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd $LAZYFLASHER_DIR
make VERSION=$VER NAME=$BASE_VER

if [ $COLOR_TXT == 1 ]; then
	tput sgr0
fi

# Cleanup remains of the kernel build (drivers etc.)
cd $KERNEL_DIR
git clean -d -f -x > /dev/null 2>&1

# Copy the ZIP to the Output
cd $LAZYFLASHER_DIR
mv $LAZYFLASHER_DIR/*.zip $ZIP_MOVE
mv $LAZYFLASHER_DIR/*.sha1 $ZIP_MOVE

# Check if a zImage was created
file1="$LAZYFLASHER_DIR/zImage"
if [ -e $file1 ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;32mThe zImage of the kernel was created successful"
	tput sgr0
else
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mThere is no zImage created by the build process!"
	echo -e "\E[1;31mCheck the the build history for errors and fix them in the kernel source."
	tput sgr0
fi

# Check if lazyflasher made a .zip and this is working right
file2="$ZIP_MOVE/*.zip"
if [ -e $file1 ] &&  [ -e $file2 ]; then
if [ $CLEAR_ON_SUCCESS == 1 ]; then
	rm ~/.bash_history
	clear
fi
	echo -e "\E[1;32mThe ZIP is created successful"
	echo -e ""
	echo -e "\E[1;32mYou can find the compiled file inside of $ZIP_MOVE"
	echo -e ""
	echo -e "\E[1;32mSuccess!"
	echo -e ""
	echo -e ""
	tput sgr0
elif [ ! -e $file1 ] ||  [ -e "$file2" ]; then
	echo -e ""
	echo -e "\E[1;31mAn error with the zImage appeared!" 
	echo -e "\E[1;31mThe build process may have created a kernel.zip but this is corrupted."
	echo -e ""
	echo -e "\E[1;31mThe device won't boot if you flash it!"
	echo -e ""
	echo -e ""
	tput sgr0
else
	echo -e "\E[1;31mThere is no kernel.zip created by the build process!"
	echo -e "\E[1;31mCheck if lazyflasher is present and if the paths are set right in the build.sh."
	echo -e ""
	echo -e ""
	tput sgr0
fi

# Cleanup remains of the *.zip build
git clean -d -f -x > /dev/null 2>&1

# Back to the roots
cd $BUILD_DIR

#!/bin/bash

# Script Initiation
workDir=$(pwd);
workExtractCpio=1;
workExtractLogo=1;

# Dependencies missing
if [ ! -f ./tools/dependencies.compiled ]; then
  echo "";
  echo " [ Running the Dependencies.sh script ]";
  echo "";
  chmod +x ./boot.img-Dependencies.sh;
  ./boot.img-Dependencies.sh "inline";
  if [ ! -f ./tools/dependencies.compiled ]; then
    echo "";
    echo " [ Please run the Dependencies.sh script ]";
    echo "";
    read key;
    exit;
  fi;
fi;

# boot.img missing
if [ ! -f ./kernel/boot.img ]; then
  echo "";
  echo " [ boot.img missing in ./kernel/ ]";
  echo "";
  read key;
  exit;
fi;

# Kernel folder
if [ ! -d ./kernel ]; then mkdir ./kernel; fi;

# Extract the boot.img
echo "";
echo " [ Extracting boot.img ]";
rm -f ./0 ./1 ./2 ./3 ./4;
cp ./kernel/boot.img ./boot.elf;
7z e ./boot.elf;
rm ./boot.elf;

# Create the workspace folder and recreate the ramdisk folder
if [ -d ./workspace ]; then rm -r ./workspace; fi;
mkdir ./workspace;
mkdir ./workspace/ramdisk;

# Attempt a bootimage proper shrink based on ELF header
if [ ! -f ./0 ] || [ ! -f ./1 ] || [ ! -f ./2 ] || [ ! -f ./3 ]; then
  echo "";
  echo " [ The boot.img is unreadable, attempting shrink ]";
  echo "";
  cmdaddr=$(od -j 152 -N 4 -tx4 -An ./kernel/boot.img \
          | cut -c 2-9);
  cmdsize=$(od -j 164 -N 4 -tx4 -An ./kernel/boot.img \
          | cut -c 2-9);
  bootsize=$((16#$cmdaddr+16#$cmdsize));
  echo "   Bootimage size found : $bootsize";
  echo "";
  dd if=./kernel/boot.img of=./boot.elf skip=0 bs=$bootsize count=1;
  7z e ./boot.elf;
  rm ./boot.elf;
fi;

# Attempt a bootimage manual shrink based on user input
if [ ! -f ./0 ] || [ ! -f ./1 ] || [ ! -f ./2 ] || [ ! -f ./3 ]; then
  echo "";
  echo " [ The boot.img is unreadable, attempting manual shrink ]";
  echo "";
  printf "   Bootimage size (refer to the cmdline end) : ";
  read bootsize;
  echo "";
  dd if=./kernel/boot.img of=./boot.elf skip=0 bs=$bootsize count=1;
  7z e ./boot.elf;
  rm ./boot.elf;
fi;

# If the boot.img hasn't been extracted correctly
if [ ! -f ./0 ] || [ ! -f ./1 ] || [ ! -f ./2 ] || [ ! -f ./3 ]; then
  echo "";
  echo " [ The boot.img is corrupted, extraction failed ]";
  echo "";
  read key;
  exit;
fi;

# Reorganize and rename the extracted files
mv -f ./0 ./workspace/kernel;
mv -f ./1 ./workspace/ramdisk.img;
mv -f ./2 ./workspace/RPM.bin;
mv -f ./3 ./workspace/cmdline.txt;
rm -f ./4;

# Extract the ramdisk image
echo "";
echo " [ Extracting ramdisk image ]";
echo "";
cd "$workDir/workspace/ramdisk/";
cp ../ramdisk.img ../ramdisk.cpio.gz;
gzip -d ../ramdisk.cpio.gz;
cpio -i -F ../ramdisk.cpio;
rm -f ../ramdisk.cpio;

# Extract the cpio archives
if [ $workExtractCpio -eq 1 ]; then
  echo "";
  echo " [ Extracting ramdisk cpios ]";
  echo "";
  cd "$workDir/workspace/ramdisk/sbin/";
  if [ -d ./ramdiskcpio ]; then rm -r ./ramdiskcpio; fi;
  if [ -d ./ramdiskrecoverycpio ]; then rm -r ./ramdiskrecoverycpio; fi;
  mkdir ./ramdiskcpio;
  mkdir ./ramdiskrecoverycpio;
  cd "$workDir/workspace/ramdisk/sbin/ramdiskcpio/";
  cpio -i -F ../ramdisk.cpio;
  cd "$workDir/workspace/ramdisk/sbin/ramdiskrecoverycpio/";
  cpio -i -F ../ramdisk-recovery.cpio;
  cd "$workDir/workspace/ramdisk/sbin/";
  rm -f ./ramdisk.cpio;
  rm -f ./ramdisk-recovery.cpio;
fi;

# Extract the ramdisk logo image
if [ $workExtractLogo -eq 1 ] && [ -z $1 ]; then
  cd "$workDir/";
  echo ""
  echo " [ Converting the logo.rle ]";
  echo "";
  ./tools/5652rgb -rle < ./workspace/ramdisk/logo.rle > ./workspace/ramdisk/logo.raw;
  convert -depth 8 -size 720x1280 rgb:./workspace/ramdisk/logo.raw ./workspace/ramdisk/logo.png;
  rm -f ./workspace/ramdisk/logo.raw;
  rm -f ./workspace/ramdisk/logo.rle;
fi;

# Script end
echo "";
echo " [ Done ]";
echo "";
if [ -z "$1" ]; then
  read key;
fi;


#!/bin/bash

# Script Initiation
workDir=$(pwd);

# Dependencies missing
if [ ! -f ./tools/dependencies.compiled ]; then
  echo "";
  echo " [ Please run the Dependencies.sh script ]";
  echo "";
  read key;
  exit;
fi;

# Kernel folder
if [ ! -d ./kernel ]; then mkdir ./kernel; fi;

# If the ramdisk folder exists
if [ -d ./workspace/ramdisk ]; then

  # If the logo has to be comCpiled
  if [ -f ./workspace/ramdisk/logo.png ]; then

    # Compile the logo.rle
    echo "";
    echo " [ Creating the logo.rle ]";
    echo "";
    if [ -f ./workspace/ramdisk/logo.rle ]; then rm ./workspace/ramdisk/logo.rle; fi;
    mv ./workspace/ramdisk/logo.png ./workspace/logo.png;
    convert -depth 8 -size 720x1280 ./workspace/logo.png rgb:./workspace/logo.raw;
    ./tools/rgb2565 -rle < ./workspace/logo.raw > ./workspace/ramdisk/logo.rle;
    rm -f ./workspace/logo.raw;

  fi;

  # If the boot logo is missing
  if [ ! -f ./workspace/ramdisk/logo.rle ]; then
    echo "";
    echo " [ Error: logo.rle missing ]";
    echo "";
    exit;
  fi;

  # If the ramdisk cpios have to be compiled
  if [ -d ./workspace/ramdisk/sbin/ramdiskcpio ] && [ -d ./workspace/ramdisk/sbin/ramdiskrecoverycpio ]; then

    # Compile the ramdisk.cpio and ramdisk.recovery.cpio
    echo "";
    echo " [ Compiling the ramdisk cpios ]";
    echo "";
    cd "$workDir/workspace/ramdisk/sbin/";
    if [ -f ./ramdisk.cpio ]; then rm -f ./ramdisk.cpio; fi;
    if [ -f ./ramdisk-recovery.cpio ]; then rm -f ./ramdisk-recovery.cpio; fi;
    cd "$workDir/workspace/ramdisk/sbin/ramdiskcpio/";
    find . | cpio -o -R 0:0 -H newc -O ../ramdisk.cpio;
    cd "$workDir/workspace/ramdisk/sbin/ramdiskrecoverycpio/";
    find . | cpio -o -R 0:0 -H newc -O ../ramdisk-recovery.cpio;

    # Move the work ramdisk files
    cd "$workDir/";
    mv ./workspace/ramdisk/sbin/ramdiskcpio ./workspace/ramdiskcpio;
    mv ./workspace/ramdisk/sbin/ramdiskrecoverycpio ./workspace/ramdiskrecoverycpio;

  fi;

  # Compile ramdisk image
  echo "";
  echo " [ Compiling the ramdisk image ]";
  echo "";
  cd "$workDir/workspace/ramdisk/";
  if [ -f ../ramdisk.img ]; then rm ../ramdisk.img; fi;
  find . | cpio -o -R 0:0 -H newc -O ../ramdisk.cpio;
  gzip -9 -n ../ramdisk.cpio;
  mv ../ramdisk.cpio.gz ../ramdisk.img;

  # Post ramdisk reorganization
  cd "$workDir/";
  if [ -d ./workspace/ramdiskcpio ] && [ -d ./workspace/ramdiskrecoverycpio ]; then
    mv ./workspace/ramdiskcpio ./workspace/ramdisk/sbin/ramdiskcpio;
    mv ./workspace/ramdiskrecoverycpio ./workspace/ramdisk/sbin/ramdiskrecoverycpio;
    rm -f ./workspace/ramdisk/sbin/ramdisk.cpio;
    rm -f ./workspace/ramdisk/sbin/ramdisk-recovery.cpio;
  fi;
  if [ -f ./workspace/logo.png ]; then
    mv ./workspace/logo.png ./workspace/ramdisk/logo.png;
    rm -f ./workspace/ramdisk/logo.rle;
  fi;

fi;

# boot.img contents missing
cd "$workDir/workspace/";
if [ ! -f ./kernel ] || [ ! -f ./ramdisk.img ] || [ ! -f ./RPM.bin ] || [ ! -f ./cmdline.txt ]; then
  echo "";
  echo " [ A file is missing for the boot.img compilation ]";
  echo "";
  read key;
  exit;
fi;

# Compile elf image
echo "";
echo " [ Compiling the boot.img ]";
echo "";
cp ../tools/mkelf.py ./mkelf.py;
python ./mkelf.py -o boot-new.elf kernel@0x80208000 ramdisk.img@0x81900000,ramdisk RPM.bin@0x00020000,rpm cmdline.txt@0x00000000,cmdline;
rm ./mkelf.py;

# Replace the new boot image
cd "$workDir/";
if [ -f ./kernel/boot-new.img ]; then rm ./kernel/boot-new.img; fi;
mv ./workspace/boot-new.elf ./kernel/boot-new.img;

# Script end
echo "";
echo " [ Done ]";
echo "";
if [ -z $1 ]; then
  read key;
fi;


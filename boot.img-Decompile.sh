# Script Initiation
workDir=$(pwd);
workExtractCpio=1;
workExtractLogo=1;

# Dependencies missing
if [ ! -f ./tools/dependencies.compiled ]; then
  echo "";
  echo " [ Please run the Dependencies.sh script ]";
  echo "";
  read key;
  exit;
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
cp ./kernel/boot.img ./boot.elf;
7z e ./boot.elf;
rm ./boot.elf;

# Create the workspace folder and recreate the ramdisk folder
if [ -d ./workspace ]; then rm -r ./workspace; fi;
mkdir ./workspace;
mkdir ./workspace/ramdisk;

# If the boot.img hasn't been extracted correctly
cd "$workDir/";
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
if [ $workExtractLogo -eq 1 ]; then
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
read key;


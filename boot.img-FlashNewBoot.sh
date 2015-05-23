# boot.img missing
if [ ! -f ./kernel/boot-new.img ]; then
  echo "";
  echo " [ boot-new.img missing in ./kernel/. Please Compile one... ]";
  echo "";
  read key;
  exit;
fi;

# Folder cleaning
echo "";
echo " [ Flashing boot-new.img ]";
echo "";
cd ./kernel/;
sudo fastboot flash boot boot-new.img;
sudo fastboot reboot;

# Script end
echo "";
echo " [ Done ]";
echo "";
read key;


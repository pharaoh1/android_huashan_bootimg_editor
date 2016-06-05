#!/bin/bash

# apt-get dependencies
sudo apt-get install gzip;
sudo apt-get install p7zip-full;
sudo apt-get install imagemagick;
sudo apt-get install syslinux;
sudo apt-get install syslinux-utils;
sudo apt-get install gcc;
gcc -O2 -Wall -Wno-unused-parameter -Wno-unused-result -o ./tools/5652rgb ./tools/from565.c;
gcc -O2 -Wall -Wno-unused-parameter -Wno-unused-result -o ./tools/rgb2565 ./tools/to565.c;
echo "" > ./tools/dependencies.compiled;

# Script end
echo "";
echo " [ Done ]";
echo "";
if [ -z "$1" ]; then
  read key;
fi;


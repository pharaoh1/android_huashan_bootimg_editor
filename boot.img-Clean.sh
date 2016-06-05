#!/bin/bash

# Folder cleaning
echo "";
echo " [ Cleaning the workspace ]";
echo "";
if [ -d ./workspace ]; then rm -r ./workspace; fi;
if [ -f ./tools/5652rgb ]; then rm -f -v ./tools/5652rgb; fi;
if [ -f ./tools/rgb2565 ]; then rm -f -v ./tools/rgb2565; fi;
if [ -f ./tools/dependencies.compiled ]; then rm -f -v ./tools/dependencies.compiled; fi;
if [ -f ./kernel/boot-new.img ]; then rm -f -v ./kernel/boot-new.img; fi;

# Script end
echo "";
echo " [ Done ]";
echo "";
if [ -z $1 ]; then
  read key;
fi;


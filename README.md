# Android - Xperia SP - boot.img Editor

These shell scripts are meant to help you
decompile and recompile the complete boot.img kernel.

They are prebuilt for the Xperia SP CM12.1 kernels
and it is recommended that you use Ubuntu (15.04). 



### [ boot.img-Decompile.sh ]
- Extract the boot.img
- Extract the ramdisk.img
- Extract the ramdisk.cpio
- Extract the ramdisk.recovery.cpio
- Export the logo.rle to logo.png

### [ boot.img-Compile.sh ]
- Rebuild the logo.rle
- Rebuild the cpios
- Rebuild the ramdisk.img
- Rebuild the boot.img

### [ boot.img-Dependencies.sh ]
- Install and build tools

### [ boot.img-Clean.sh ]
- Delete all temporary files

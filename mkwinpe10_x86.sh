#! /bin/bash --
#
# by pts@fazekas.hu at Sun Jan 14 10:36:53 CET 2018
#
# This shell script builds winpe10_x64.iso, which is Windows PE 10, which
# corresponds to 32-bit Windows 10 (released on 2017-09), version 1709.
#

set -ex

# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515921750 sha256=e0d9ede31e4f6780f2ca17c8c790e8262416247dc272b7666862b8ba72ad497b size=3868639232 f=win10_x86.iso
# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515929799 sha256=7435c71161cea977b6760a769bcbff14c50c588b3fc5a46560a913ec6671e743 size=311529472 f=winpe10_x86.iso
# format=? hdr_done_at=64 mtime=1513209832 sha256=8c42cac0bff1dab4a2be73f8309d6d38bd16873c9517f9f0cab002f3255625ea size=330165924 f=win10_x86.x/sources/boot.wim
# format=? hdr_done_at=64 mtime=1506658829 sha256=2a8548518ba7276838887c3f7c596c5054a857c4fc23a12058eb4ef2d681dd42 size=397752 f=winpe10_x86.dir/bootmgr
# format=? hdr_done_at=64 mtime=1506129387 sha256=f425e135aac26b55e2bac655e62e2ce0b16255226c583d9ab43b2e93e8a6d932 size=4096 f=winpe10_x86.dir/etfsboot.com
# format=? hdr_done_at=64 mtime=1506649562 sha256=8969671fe3db30cc8e4dc6f437fa6ad4bdde8e2cf61b7911c84169b3c16ba1d7 size=16384 f=winpe10_x86.dir/boot/bcd
# format=? hdr_done_at=64 mtime=1506129360 sha256=cd2c00ce027687ce4a8bdc967f26a8ab82f651c9becd703658ba282ec49702bd size=3170304 f=winpe10_x86.dir/boot/boot.sdi
# format=? hdr_done_at=64 mtime=1515922992 sha256=a5fa94f394c7015707007a3b36da255ea76bf35bf37c7887a7a4ab6fc9655f94 size=307587183 f=winpe10_x86.dir/sources/boot.wim
# -rw-r----- 1 pts pts 3868639232 Jan 14  2018 win10_x86.iso
# -rw-r----- 1 pts pts  330165924 Dec 14  2017 win10_x86.x/sources/boot.wim
# -rw-r----- 1 pts pts      16384 Sep 29  2017 winpe10_x86.dir/boot/bcd
# -rw-r----- 1 pts pts    3170304 Sep 23  2017 winpe10_x86.dir/boot/boot.sdi
# -rw-r----- 1 pts pts     397752 Sep 29  2017 winpe10_x86.dir/bootmgr
# -rw-r----- 1 pts pts       4096 Sep 23  2017 winpe10_x86.dir/etfsboot.com
# -rw-r----- 1 pts pts  307587183 Jan 14  2018 winpe10_x86.dir/sources/boot.wim
# -rw-r----- 1 pts pts  311529472 Jan 14  2018 winpe10_x86.iso

type -p 7z
type -p wimlib-imagex
type -p genisoimage
# en_windows_10_multi-edition_vl_version_1709_updated_dec_2017_x86_dvd_100406182.iso
test -f win10_x86.iso

export LC_CTYPE=C  # For case insensitive extraction.

rm -rf winpe10_x86.dir
mkdir winpe10_x86.dir winpe10_x86.dir/boot winpe10_x86.dir/sources

rm -rf win10_x86.x
mkdir  win10_x86.x
7z -owin10_x86.x -y x win10_x86.iso sources/boot.wim
wimlib-imagex export win10_x86.x/sources/boot.wim 2 --boot winpe10_x86.dir/sources/boot.wim
rm -f win10_x86.x/sources/boot.wim
# winpesh.ini:
#   [LaunchApps]
#   %SYSTEMDRIVE%\\$start_script_base
# add '$start_script' '/$start_script_base'
# delete --force /Windows/System32/winpeshl.ini
# add '$tmp_dir/__mkwinpeimg.winpeshl.ini' /Windows/System32/winpeshl.ini
# add '$overlay' /
echo "
rename /setup.exe /setup.exe.orig
rename /sources/setup.exe /sources/setup.exe.orig
" >win10_x86.x/cmds
WIMLIB_IMAGEX_IGNORE_CASE=1 wimlib-imagex update winpe10_x86.dir/sources/boot.wim --rebuild <win10_x86.x/cmds

7z -owin10_x86.x -y -ssc- x win10_x86.iso BOOT/ETFSBOOT.COM
mv $(find win10_x86.x -iname ETFSBOOT.COM) winpe10_x86.dir/etfsboot.com
7z -owin10_x86.x -y -ssc- x win10_x86.iso BOOTMGR
mv $(find win10_x86.x -iname BOOTMGR) winpe10_x86.dir/bootmgr
7z -owin10_x86.x -y -ssc- x win10_x86.iso BOOT/BOOT.SDI
mv $(find win10_x86.x -iname BOOT.SDI) winpe10_x86.dir/boot/boot.sdi
7z -owin10_x86.x -y -ssc- x win10_x86.iso BOOT/BCD
mv $(find win10_x86.x -iname BCD) winpe10_x86.dir/boot/bcd

rm -rf win10_x86.x

# mkisofs also works.
genisoimage -input-charset ascii -sysid "" -A "" -V "Microsoft Windows PE (x86)" -d -N -b etfsboot.com -no-emul-boot -c boot.cat -hide etfsboot.com -hide boot.cat -o winpe10_x86.iso winpe10_x86.dir
rm -rf winpe10_x86.dir

# SUXX: Doesn't boot in QEMU 2.0.0: Stuck on the logo screen for 10 minutes.
# This doesn't work either: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-i386 -enable-kvm -machine pc-q35-1.4,accel=kvm -drive file=winpe10_x86.iso,if=scsi,media=cdrom,readonly -boot d -m 1200 -localtime  -net nic -net user -smb "$PWD"
: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-i386 -enable-kvm -machine pc-1.0,accel=kvm -cdrom winpe10_x86.iso -boot d -m 300 -localtime  -net nic -net user -smb "$PWD"
# -hda winpe10_x86hdd.img
# X:\windows\system32>net use s: \\10.0.2.4\qemu

: mkwinpe10_x86.sh OK.

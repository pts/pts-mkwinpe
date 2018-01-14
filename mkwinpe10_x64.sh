#! /bin/bash --
#
# by pts@fazekas.hu at Sun Jan 14 10:36:53 CET 2018
#
# This shell script builds winpe10_x64.iso, which is Windows PE 10, which
# corresponds to 64-bit Windows 10 (released on 2017-09), version 1709.
#

set -ex

# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515921647 sha256=f38b0aeae0756e01dcd9b1600de62416e04aa963c72cea30929141f54f1235b3 size=5035036672 f=win10_x64.iso
# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515930091 sha256=5d698d30d34bc1939ad5d75d5d97672e35d1ae7f9e5608754114aa6b18cb67ef size=323624960 f=winpe10_x64.iso
# format=? hdr_done_at=64 mtime=1513219247 sha256=c44df9779c2ac16b1cc377899f61ac7ccbc46c080f3419bbfc0fd5c89a08d61a size=413901981 f=win10_x64.x/sources/boot.wim
# format=? hdr_done_at=64 mtime=1506658829 sha256=2a8548518ba7276838887c3f7c596c5054a857c4fc23a12058eb4ef2d681dd42 size=397752 f=winpe10_x64.dir/bootmgr
# format=? hdr_done_at=64 mtime=1506129387 sha256=f425e135aac26b55e2bac655e62e2ce0b16255226c583d9ab43b2e93e8a6d932 size=4096 f=winpe10_x64.dir/etfsboot.com
# format=? hdr_done_at=64 mtime=1506649562 sha256=8969671fe3db30cc8e4dc6f437fa6ad4bdde8e2cf61b7911c84169b3c16ba1d7 size=16384 f=winpe10_x64.dir/boot/bcd
# format=? hdr_done_at=64 mtime=1506129360 sha256=cd2c00ce027687ce4a8bdc967f26a8ab82f651c9becd703658ba282ec49702bd size=3170304 f=winpe10_x64.dir/boot/boot.sdi
# format=? hdr_done_at=64 mtime=1515922992 sha256=a5fa94f394c7015707007a3b36da255ea76bf35bf37c7887a7a4ab6fc9655f94 size=307587183 f=winpe10_x64.dir/sources/boot.wim
# -rw-r----- 1 pts pts 5035036672 Jan 14  2018 win10_x64.iso
# -rw-r----- 1 pts pts  413901981 Dec 14  2017 win10_x64.x/sources/boot.wim
# -rw-r----- 1 pts pts      16384 Sep 29  2017 winpe10_x64.dir/boot/bcd
# -rw-r----- 1 pts pts    3170304 Sep 29  2017 winpe10_x64.dir/boot/boot.sdi
# -rw-r----- 1 pts pts     397752 Sep 29  2017 winpe10_x64.dir/bootmgr
# -rw-r----- 1 pts pts       4096 Sep 23  2017 winpe10_x64.dir/etfsboot.com
# -rw-r----- 1 pts pts  319684450 Jan 14  2018 winpe10_x64.dir/sources/boot.wim
# -rw-r----- 1 pts pts  323624960 Jan 14  2018 winpe10_x64.iso

type -p 7z
type -p wimlib-imagex
type -p genisoimage
# en_windows_10_multi-edition_vl_version_1709_updated_dec_2017_x64_dvd_100406172.iso
test -f win10_x64.iso

export LC_CTYPE=C  # For case insensitive extraction.

rm -rf winpe10_x64.dir
mkdir winpe10_x64.dir winpe10_x64.dir/boot winpe10_x64.dir/sources

rm -rf win10_x64.x
mkdir  win10_x64.x
7z -owin10_x64.x -y x win10_x64.iso sources/boot.wim
wimlib-imagex export win10_x64.x/sources/boot.wim 2 --boot winpe10_x64.dir/sources/boot.wim
rm -f win10_x64.x/sources/boot.wim
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
" >win10_x64.x/cmds
WIMLIB_IMAGEX_IGNORE_CASE=1 wimlib-imagex update winpe10_x64.dir/sources/boot.wim --rebuild <win10_x64.x/cmds

7z -owin10_x64.x -y -ssc- x win10_x64.iso BOOT/ETFSBOOT.COM
mv $(find win10_x64.x -iname ETFSBOOT.COM) winpe10_x64.dir/etfsboot.com
7z -owin10_x64.x -y -ssc- x win10_x64.iso BOOTMGR
mv $(find win10_x64.x -iname BOOTMGR) winpe10_x64.dir/bootmgr
7z -owin10_x64.x -y -ssc- x win10_x64.iso BOOT/BOOT.SDI
mv $(find win10_x64.x -iname BOOT.SDI) winpe10_x64.dir/boot/boot.sdi
7z -owin10_x64.x -y -ssc- x win10_x64.iso BOOT/BCD
mv $(find win10_x64.x -iname BCD) winpe10_x64.dir/boot/bcd

rm -rf win10_x64.x

genisoimage -input-charset ascii -sysid "" -A "" -V "Microsoft Windows PE (x64)" -d -N -b etfsboot.com -no-emul-boot -c boot.cat -hide etfsboot.com -hide boot.cat -o winpe10_x64.iso winpe10_x64.dir
rm -rf winpe10_x64.dir

# SUXX: Doesn't boot in QEMU 2.0.0: Stuck in a reboot loop with an error message, stop code: SYSTEM THREAD EXCEPTION NOT HANDLED.
# This doesn't work either: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-x64_64 -enable-kvm -machine pc-q35-1.4,accel=kvm -drive file=winpe10_x64.iso,if=scsi,media=cdrom,readonly -boot d -m 1200 -localtime  -net nic -net user -smb "$PWD"
: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-x64_64 -enable-kvm -machine pc-1.0,accel=kvm -cdrom winpe10_x64.iso -boot d -m 300 -localtime  -net nic -net user -smb "$PWD"
# -hda winpe10_x64hdd.img
# X:\windows\system32>net use s: \\10.0.2.4\qemu

: mkwinpe10_x64.sh OK.

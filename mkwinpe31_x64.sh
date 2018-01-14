#! /bin/bash --
#
# by pts@fazekas.hu at Sun Jan 14 01:57:20 CET 2018
#
# This shell script builds winpe31_x64.iso, which is 64-bit Windows PE 3.1,
# which corresponds to Windows 7 SP1 (released on 2011-02-22), Windows 6.1.7601.
#

set -ex

# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515890287 sha256=eb67dd28aa35270554472f128278540c64dc726bb08f9c58140ec7aa7950c8ae size=1353234432 f=waik_supplement_en-us.iso
# format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515926779 sha256=afe185164ae95780d3975ccbd8a0145219ee3cfa06887ae819194b94856f3ed1 size=139651072 f=winpe31_x64.iso
# format=? hdr_done_at=64 mtime=1290256807 sha256=0769a292114dfe181dc4931159c24cd7adb6a3f3823177e40eb45ee59688ea4a size=383786 f=winpe31_x64.dir/bootmgr
# format=? hdr_done_at=64 mtime=1244668450 sha256=f425e135aac26b55e2bac655e62e2ce0b16255226c583d9ab43b2e93e8a6d932 size=4096 f=winpe31_x64.dir/etfsboot.com
# format=? hdr_done_at=64 mtime=1288921961 sha256=b3357aa4b3fb0f1dc2a9acd5787d3be7a36d8494ac52b8d385699c376a76af90 size=262144 f=winpe31_x64.dir/boot/bcd
# format=? hdr_done_at=64 mtime=1288923498 sha256=cd2c00ce027687ce4a8bdc967f26a8ab82f651c9becd703658ba282ec49702bd size=3170304 f=winpe31_x64.dir/boot/boot.sdi
# format=? hdr_done_at=64 mtime=1290269744 sha256=ba089d1c75c626a171d6d47fcf58884f842106ebf30d9d8464b87a7534943c6c size=135464046 f=winpe31_x64.dir/sources/boot.wim
# -rw-r----- 1 pts pts 1353234432 Jan 14  2018 waik_supplement_en-us.iso
# -rw-r----- 1 pts eng     262144 Nov  5  2010 winpe31_x64.dir/boot/bcd
# -rw-r----- 1 pts eng    3170304 Nov  5  2010 winpe31_x64.dir/boot/boot.sdi
# -rw-r----- 1 pts eng     383786 Nov 20  2010 winpe31_x64.dir/bootmgr
# -rw-r----- 1 pts eng       4096 Jun 10  2009 winpe31_x64.dir/etfsboot.com
# -rw-r----- 1 pts eng  135464046 Nov 20  2010 winpe31_x64.dir/sources/boot.wim
# -rw-r----- 1 pts pts  139651072 Jan 14  2018 winpe31_x64.iso

type -p 7z
type -p genisoimage
test -f waik_supplement_en-us.iso  # Windows 7 SP1; Download it from http://www.microsoft.com/en-us/download/details.aspx?id=5188  (published 2011-02-21)

rm -rf winpe31_x64.dir
mkdir winpe31_x64.dir winpe31_x64.dir/boot winpe31_x64.dir/sources

rm -rf waik.x
mkdir  waik.x
7z -owaik.x x waik_supplement_en-us.iso AMD64/BOOT/ETFSBOOT.COM
mv waik.x/AMD64/BOOT/ETFSBOOT.COM winpe31_x64.dir/etfsboot.com
7z -owaik.x x waik_supplement_en-us.iso AMD64/BOOTMGR
mv waik.x/AMD64/BOOTMGR winpe31_x64.dir/bootmgr
7z -owaik.x x waik_supplement_en-us.iso AMD64/BOOT/BOOT.SDI
mv waik.x/AMD64/BOOT/BOOT.SDI winpe31_x64.dir/boot/boot.sdi
7z -owaik.x x waik_supplement_en-us.iso AMD64/BOOT/BCD
mv waik.x/AMD64/BOOT/BCD winpe31_x64.dir/boot/bcd
7z -owaik.x x waik_supplement_en-us.iso AMD64/WINPE.WIM
mv waik.x/AMD64/WINPE.WIM winpe31_x64.dir/sources/boot.wim
rm -rf waik.x

genisoimage -input-charset ascii -sysid "" -A "" -V "Microsoft Windows PE (x64)" -d -N -b etfsboot.com -no-emul-boot -c boot.cat -hide etfsboot.com -hide boot.cat -o winpe31_x64.iso winpe31_x64.dir
#rm -rf winpe31_x64.dir

: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-x86_64 -enable-kvm -machine pc-1.0,accel=kvm -cdrom winpe31_x64.iso -boot d -m 300 -localtime  -net nic -net user -smb "$PWD"
# -hda winpe31_x64hdd.img

# X:\windows\system32>ver
#
# Microsoft Windows [Version 6.1.7601]
#
# https://www.gaijin.at/en/lstwinver.php
#
# X:\windows\system32>net use s: \\10.0.2.4\qemu

: mkwinpe31_x64.sh OK.

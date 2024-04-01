#!/usr/bin/env bash

source $PWD/helpers/vars.sh
source $PWD/helpers/deobfuscate_payload.sh
source $PWD/helpers/substitute.sh

# Original script had a binary comment and a ####Hello#### header (useless)
# Original script also checked for linux, instead of exiting we're just echoing a warn

[ ! $(uname) = "Linux" ] && echo "Stage 1 script would have exited here"

# Original was getting it's source directory with `grep ^srcdir= config.status` after running ./configure

# The payload archive contains both the evil .so and the stage 2 script, this will fetch the script and write it to stage2.sh
# The .so is 31232 bytes in 5.6.1, and 31264 in 5.6.0 (+1 due to tail)

# Deobfuscate payload and fetch the compressed script
echo "decode stage 2 from ${PAYLOAD_FILE}: extract payload and decode"
xz -dc "$XZPATH/tests/files/$PAYLOAD_FILE" | deobfuscate_payload | tail -c +31233 | substitute > "$ARTIFACTS/stage2.sh.xz"

# Decompress stage 2 script and write it
# -F raw is file format (not an archive, but raw lzma data, with no header)
# -lzma1 is the algorithm version to use (vs lzma2)
echo "decode stage 2 from ${PAYLOAD_FILE}: decompress stage 2 and write it"
xz -F raw --lzma1 -dc "$ARTIFACTS/stage2.sh.xz" > "$ARTIFACTS/stage2.sh"

#!/usr/bin/env bash

source $PWD/helpers/vars.sh
source $PWD/helpers/deobfuscate_payload.sh

# Original script had a binary comment and a ####Hello#### header (useless)
# Original script also checked for linux, instead of exiting we're just echoing a warn

[ ! $(uname) = "Linux" ] && echo "Stage 1 script would have exited here"

# Original was getting it's source directory with `grep ^srcdir= config.status` after running ./configure

# The payload archive contains both the evil .so and the stage 2 script, this will fetch the script and write it to stage2.sh
# The .so is 31232 bytes in 5.6.1, and 31264 in 5.6.0 (+1 due to tail)

# Deobfuscate payload and fetch the compressed script
# The decode table is 6 ranges of bytes that maps to 0x00-0xff
# TODO: comment the table (in hex, not octal)
DECODE_TABLE="\114-\321\322-\377\35-\47\14-\34\0-\13\50-\113"
# This is the decode table for 5.6.0
# DECODE_TABLE="\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131"
echo "decode stage 2 from ${PAYLOAD_FILE}: extract payload and decode"
xz -dc "$XZPATH/tests/files/$PAYLOAD_FILE" | deobfuscate_payload | tail -c +31233 | tr "$DECODE_TABLE" "\0-\377" > "$ARTIFACTS/stage2.sh.xz"

# Decompress stage 2 script and write it
# -F raw is file format (not an archive, but raw lzma data, with no header)
# -lzma1 is the algorithm version to use (vs lzma2)
echo "decode stage 2 from ${PAYLOAD_FILE}: decompress stage 2 and write it"
xz -F raw --lzma1 -dc "$ARTIFACTS/stage2.sh.xz" > "$ARTIFACTS/stage2.sh"

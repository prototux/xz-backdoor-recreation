#!/usr/bin/env bash

source $PWD/helpers/vars.sh

# Decode the stage 1 as the stage 0 do

## Get tests/files/bad-3-corrupt_lzma2.xz and "uncorrupt" it
# The tr swaps the following bytes to fix the xz archive: 0x09 => 0x20, 0x20 => 0x09, 0x2d => 0x5f, 0x5f => 0x2d
echo "decode stage1 ${STAGE1_FILE} into ${STAGE1_ARTIFACT}: Fix xz archive"
sed -r "r\n" "$XZPATH/tests/files/$STAGE1_FILE" | tr "\t \-_" " \t_\-" > "$PWD/artifacts/${STAGE1_ARTIFACT}.xz"

## Extract stage 1
echo "decode stage1 ${STAGE1_FILE} into ${STAGE1_ARTIFACT}: Extract ${STAGE1_ARTIFACT} // the error is normal!"
cat "$PWD/artifacts/${STAGE1_ARTIFACT}.xz" | xz -d > "$PWD/artifacts/${STAGE1_ARTIFACT}"

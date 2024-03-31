XZPATH="$PWD/xz-5.6.1"
ARTIFACTS="$PWD/artifacts"
STAGE1_FILE="bad-3-corrupt_lzma2.xz"
STAGE1_ARTIFACT="bad-3-corrupt-lzma2.sh"
PAYLOAD_FILE="good-large_compressed.lzma"
# The decode table is 6 ranges of bytes that maps to 0x00-0xff
# TODO: comment the table (in hex, not octal)
DECODE_TABLE="\114-\321\322-\377\35-\47\14-\34\0-\13\50-\113"
# This is the decode table for 5.6.0
# DECODE_TABLE="\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131"

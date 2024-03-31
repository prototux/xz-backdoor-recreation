deobfuscate_payload() {
	# Original was
	# ( \
	#   (head -c +1024 >/dev/null) && head -c +2048 && \ (repeated 16 times)
	# )

	# This will do multiple pass of removing the first 1024 bytes then getting 2048 bytes of data, this is to remove the 0x41/'A' chars that are here to obfuscate the stage 2 data
	for i in {1..16}; do
		head -c +1024 > /dev/null # Discard 1024 bytes
		head -c +2048 # Output 2048 bytes
	done
	# Finally output the last 939 bytes (was 724 in 5.6.0)
	head -c +1024 > /dev/null
	head -c +939
}

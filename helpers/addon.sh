source $PWD/helpers/substitute.sh

# This is the "addon" code, aka "stage 3" that is in stage 2, but the files who matches wasn't commited
# Called like so: addon (path to search in) (start pattern) (end pattern)
addon() {
	path="$1"
	start_match="$2"
	end_match="$3"
	start=$(grep -broaF "$start_match" "$path" 2>/dev/null)
	end=$(grep -broaF "$end_match" "$path" 2>/dev/null)

	# If anything was found for both start and end offset
	if [[ "x$start" != "x" && "x$end" != "x" ]]; then
		# Check that start and end matches the same file, else exit
		start_file=$(echo "$start" | cut -d':' -f1)
		end_file=$(echo "$end" | cut -d':' -f1)
		if [[ "x$start_file" != "x$end_file" ]]; then
			echo "addon: file $start_file and $end_file doesn't match!"
			exit 0
		fi

		# Check that the file exists at all
		addon_file="$start_file"
		if [[ ! -f "$addon_file" ]]; then
			echo "addon: file $addon_file doesn't exist!"
			exit 0
		fi

		# Now, everything is ok, so we can carve out, decode/decrypt and execute the addon script
		start_offset=$(( $(echo "$start" | cut -d':' -f2) + 7))
		end_offset=$(( $(echo "$end" | cut -d':' -f2) - $start_offset))
		cat $addon_file | tail -c +$start_ofsset | head -c +$end_offset | substitute | xz -F raw -lzma2 -dc > "$ARTIFACTS/addon.sh"
		# This would have been eval'd
		# eval $(cat "$ARTIFACTS/addon.sh")"
	fi
}

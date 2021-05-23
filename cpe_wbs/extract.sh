#!/bin/bash
set -eux -o pipefail

firmware="$1"
output="$2"

mkdir -p "$output"

case "$firmware" in
    *-APPLC.bin) header_size="0x1050" ;;
    *)           header_size="0x1014" ;;
esac

grep -ao 'fwup-ptn .*$' "$firmware" | while read line; do
    name="$(echo $line | awk '{print $2}')"
    base="$(echo $line | awk '{print $4}')"
    size="$(echo $line | awk '{print $6}')"
    dd if="$firmware" of="$output/$name" iflag=skip_bytes skip=$(($(printf '%d' "$header_size") + $(printf '%d' "$base"))) bs=$(printf '%d' "$size") count=1
done

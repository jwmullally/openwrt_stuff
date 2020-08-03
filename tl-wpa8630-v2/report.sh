#!/bin/bash
set -eux -o pipefail

rm -rf report && mkdir report report/partitions report/firmwares && cd report

echo "firmware;partitions_hash;support_list" > report.csv

for filename in ../firmware/*.bin; do
    firmware="$(basename $filename)"
    dirname="firmwares/$firmware"
    mkdir "$dirname"
    #tplink-safeloader -x "$filename" -d "$dirname"  # 2020 OpenWrt snapshot tplink-safeloader doesn't work with APPLC.bin files
    grep -ao "fwup-ptn .*$" "$filename" > "$dirname/fwup-ptn.txt"
    grep -ao "partition .*$" "$filename" > "$dirname/partition.txt"
    grep -ao "\{product_name:.*\}" "$filename" > "$dirname/support_list.txt"
    partition_hash=($(md5sum "$dirname/partition.txt"))
    cat "$dirname/partition.txt" > "partitions/$partition_hash.txt"
    support_list=$(cat "$dirname/support_list.txt")
    for support_list_entry in $support_list; do
        echo "$firmware;$partition_hash;$support_list_entry" >> report.csv
    done
done

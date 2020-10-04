#!/bin/bash
set -eux -o pipefail

rm -rf report && mkdir report report/partitions report/firmwares report/content_hashes && cd report

echo "firmware	partitions_hash	support_list" > report.tsv
echo -n "partition," > content_hashes.csv

for filename in ../firmware/*.bin; do
    firmware="$(basename $filename)"
    dirname="firmwares/$firmware"
    mkdir "$dirname" "$dirname/partitions"
    ../extract.sh "$filename" "$dirname/partitions"
    echo -n "$firmware," >> content_hashes.csv
    grep -ao "fwup-ptn .*$" "$filename" > "$dirname/fwup-ptn.txt"
    grep -ao "partition .*$" "$filename" > "$dirname/partition.txt"
    grep -ao "\{product_name:.*\}" "$filename" > "$dirname/support_list.txt"
    partition_hash=($(md5sum "$dirname/partition.txt"))
    cat "$dirname/partition.txt" > "partitions/$partition_hash.txt"
    support_list=$(cat "$dirname/support_list.txt")
    for support_list_entry in $support_list; do
        echo "$firmware	$partition_hash	$support_list_entry" >> report.tsv
    done
done

echo "" >> content_hashes.csv

for ptn in $(find . -path "./firmwares/*/partitions/*" -type f -printf "%f\n" | sort | uniq); do
    echo -n "$ptn," >> content_hashes.csv
    mkdir "content_hashes/$ptn"
    for dirname in firmwares/*; do
        firmware="$(basename $dirname)"
        if [ -f "$dirname/partitions/$ptn" ]; then
            md5="$(md5sum "$dirname/partitions/$ptn" | awk '{print $1}')"
            echo -n "$md5," >> content_hashes.csv
            echo "$firmware" >> "content_hashes/$ptn/$md5.txt"
        else
            echo -n "," >> content_hashes.csv
        fi
    done
    echo "" >> content_hashes.csv
done

#!/bin/bash
set -eux -o pipefail

rm -rf report && mkdir report report/partitions report/firmwares && cd report

echo "firmware	vendor	partition_hash	default_mac_base	default_mac_size	serial_number_base	serial_number_size	product_info_base	product_info_size" > report.tsv

for filename in ../firmware/*.bin; do
    firmware="$(basename $filename)"
    dirname="firmwares/$firmware"
    mkdir "$dirname" "$dirname/partitions"
    ../extract.sh "$filename" "$dirname/partitions"
    grep -ao "fwup-ptn .*$" "$filename" > "$dirname/fwup-ptn.txt"
    grep -ao "partition .*$" "$filename" > "$dirname/partition.txt"
    partition_hash=($(md5sum "$dirname/partition.txt"))
    cat "$dirname/partition.txt" > "partitions/$partition_hash.txt"
    vendor=$(dd if="$filename" iflag=skip_bytes skip=24 bs=50 count=1 | strings)
    default_mac_base=$(awk '/partition default-mac / {print $4}' "$dirname/partition.txt")
    default_mac_size=$(awk '/partition default-mac / {print $6}' "$dirname/partition.txt")
    serial_number_base=$(awk '/partition serial-number / {print $4}' "$dirname/partition.txt")
    serial_number_size=$(awk '/partition serial-number / {print $6}' "$dirname/partition.txt")
    product_info_base=$(awk '/partition product-info / {print $4}' "$dirname/partition.txt")
    product_info_size=$(awk '/partition product-info / {print $6}' "$dirname/partition.txt")
    echo "$firmware	$vendor	$partition_hash	$default_mac_base	$default_mac_size	$serial_number_base	$serial_number_size	$product_info_base	$product_info_size" >> report.tsv
done

# Sort all rows except header
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' report.tsv > report.tsv.tmp
mv report.tsv.tmp report.tsv

# Generate 2nd report without firmware filename, just vendor
awk 'NR == 1; NR > 1 {print $0 | "cut -d\"	\" -f2- | sort -n | uniq"}' report.tsv > report2.tsv
sed -i 's/firmware	//g' report2.tsv


echo "Finished generating report"

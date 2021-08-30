#!/bin/bash
set -eux -o pipefail

rm -rf downloads firmware && mkdir downloads firmware && cd downloads

# Grab the "url" column
URLS="$(awk 'BEGIN{ FS=","; RS="\r\n"} NR > 1 {print $4 | "sort -n | uniq"}' ../firmware_urls.csv)"
IFS='
'
for url in $URLS; do
    url=${url// /%20}
    filename="$(basename $url)"
    curl -L -O "$url"
    unzip -j "$filename" "*.bin" -d ../firmware || echo "Error extracting file, results may be incomplete"
done

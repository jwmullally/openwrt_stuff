#!/bin/bash
set -eux -o pipefail

rm -rf downloads firmware && mkdir downloads firmware && cd downloads

# Grab the "url" column
URLS="$(cat ../firmware_urls.csv | dos2unix | tail -n+2 | cut -d, -f4 | sort | uniq)"
IFS='
'
for url in $URLS; do
    url=${url// /%20}
    filename="$(basename $url)"
    curl -L -O "$url"
    unzip -j "$filename" "*.bin" -d ../firmware
done

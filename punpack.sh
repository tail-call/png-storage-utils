#!/bin/bash

# Author:   T. C. <tail-call@ponych.at>
# Date:     2016-07-02
# Modified: 2016-07-03
# Requires: netpbm, coreutils, unzip

# Extracts files from Google Photos album. Photos must be PNG files created
# with cpng from tar file splitten with split command.

file="$1"

if [[ -z "$file" ]]; then >&2 cat << EOF
Usage: punpack Photos.zip
EOF
exit 1
fi

tempdir=$(mktemp -d)

unzip -e "$file" -d "$tempdir"

for file in $tempdir/*.png
do
    >&2 echo Converting $file.
    png2pnm $file | tail -n+4 > "$file.xtr"
done

>&2 echo Catenating...
cat $tempdir/*.xtr > $tempdir/out.tar

>&2 echo Extracting...
tar -xf $tempdir/out.tar

>&2 echo Cleaning up...
rm -rf $tempdir

>&2 echo Done.

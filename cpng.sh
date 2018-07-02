#!/bin/bash

# Author:   Anton Istomin <anton@tail-call.ru>
# Date:     2016-07-01
# Modified: 2018-07-02
# Requires: netpbm, coreutils, bc

# Converts any files to PNG images. Bytes are stored as raw pixel data.
# Converting back is as simple as converting PNG to PPM with png2pnm and
# stripping the header away.

# CAUTION: trailing bytes are likely to appear in the pixel data. To work
# around this, tar files before conversion.

if [[ -z "$*" ]]; then cat << EOF
Usage: cpng [option ...] file

Options:
-w <n>		Sets the output image to be a square with width n.
		If not specified, width is calculated automatically.
-o <filename>	Write output to file named filename.
		By default writes to stdout.
EOF
exit 1
fi

while [[ -n "$*" ]]; do
  case "$1" in
    -w) shift; width="$1" ;;
    -o) shift; out="$1"   ;;
#    -) file=/dev/stdin   ;; # Broken.
     *) file="$1"         ;;
  esac
  shift
done

if [[ -z "$file" ]]; then
  >&2 echo "You must provide an input file."
  exit 127
fi

# Write to stdout by default.
if [[ -z "$out" ]]; then
  out=/dev/stdout
fi

# WC counts bytes, CUT leaves only the byte count field.
size=$(wc -c "$file" | cut -f1 -d' ')

if [[ -z "$width" ]]; then
  # One could show that square image with this width is
  # sufficient for storing `wc -c' bytes of data within
  # 3 channels (R, G, B).
  width=$(bc <<< "x=sqrt($size/3)+1; if (x*x<$size) x+1 else x")
fi

# Appends a PPM header to file, making its contents the raw pixel data.
# Then converts to PNG.
cat - "$file" << EOF | pnm2png > $out
P6
$width $width
255
EOF

#!/bin/bash

. scripts/lib.sh

cd "$BUILDDIR" || die

curl -L --fail --retry 3 "https://www.libsdl.org/release/SDL3-devel-$SDL3_VERSION-VC.zip" -o SDL3.zip || die
unzip -q SDL3.zip || die
mv "SDL3-$SDL3_VERSION" SDL3_VC || die
rm SDL3.zip

if [ ! -f "OpenRemix/public/include/remix/remix_c.h" ]; then
	echo "OpenRemix headers were not checked out" >&2
	die
fi

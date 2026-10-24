#!/bin/bash

. scripts/lib.sh

cd "$BUILDDIR" || die

./waf.bat configure -8 -3 -s "SDL3_VC" -T release \
	--enable-ref-openremix \
	--openremix-include="OpenRemix/public/include" \
	--enable-utils --enable-lto --enable-msvcdeps --enable-tui \
	|| die_configure

./waf.bat build || die
./waf.bat install --destdir=. || die

cp -v SDL3_VC/lib/x64/SDL3.dll . || die
cp -v SDL3_VC/lib/x64/SDL3.pdb . || die

WINSDK_LATEST=$(ls -1 "C:/Program Files (x86)/Windows Kits/10/bin" | grep -E '^10' | sort -rV | head -n1)
echo "Latest installed Windows SDK is $WINSDK_LATEST"

if [ -n "$FWGS_PFX_PASSWORD" ]; then
	"C:/Program Files (x86)/Windows Kits/10/bin/$WINSDK_LATEST/x64/signtool.exe" \
		sign //f scripts/fwgs.pfx //fd SHA256 //p "$FWGS_PFX_PASSWORD" ./*.dll ./*.exe \
		|| die
else
	echo "FWGS_PFX_PASSWORD is not available; leaving OpenRemix binaries unsigned"
fi

mkdir -p artifacts/
7z a -t7z "artifacts/xash3d-fwgs-openremix-win32-amd64.7z" \
	-m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on \
	./*.dll ./*.exe ./*.pdb activities.txt || die

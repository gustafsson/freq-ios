#!/bin/bash

# Compilation of fat binary based on https://github.com/jhurt/FLACiOS, with a few adjustments:
# 1. Removed all source code but libflac from compiling.
# 2. Moved the FLACiOS.a file into the framework bundle and replaced the file that was originally put there.

set -e

IOS_FLAC=src/flac
if ! [ -d "$IOS_FLAC" ]; then
  git submodule update --init src/flac
fi

rm -rf "$IOS_FLAC"/build
cp ios-flac-project.pbxproj "$IOS_FLAC"/FLACiOS.xcodeproj/project.pbxproj
pushd "$IOS_FLAC"
# -target Framework
if ! xcodebuild -alltargets -arch arm64 -arch armv7 -arch armv7s; then
	echo 'flac.framework for ios failed. Missing ogg or not using ios-flac-project.pbxproj?'
	echo '  "brew install libogg"'
	echo '  "ln -s /usr/local/include/ogg /opt/local/include/ogg"'
	false
fi

popd
rm -rf framework/flac.framework
rm -rf framework-iphonesimulator/flac.framework
mv "$IOS_FLAC"/build/Release-iphoneos/FLACiOS.framework framework/flac.framework
mv "$IOS_FLAC"/build/Release-iphonesimulator/FLACiOS.framework framework-iphonesimulator/flac.framework
rm framework/flac.framework/FLACiOS
rm framework-iphonesimulator/flac.framework/FLACiOS
ln -s Versions/Current/flac framework/flac.framework/flac
ln -s Versions/Current/flac framework-iphonesimulator/flac.framework/flac

# use original
mv framework/flac.framework/Versions/A/{FLACiOS,flac}
mv framework-iphonesimulator/flac.framework/Versions/A/{FLACiOS,flac}

# don't use original but use libFLACiOS.a instead
# rm framework/flac.framework/Versions/A/FLACiOS
# rm framework-iphonesimulator/flac.framework/Versions/A/FLACiOS
#mv "$IOS_FLAC"/build/Release-iphoneos/libFLACiOS.a framework/flac.framework/Versions/A/flac
#mv "$IOS_FLAC"/build/Release-iphonesimulator/libFLACiOS.a  framework-iphonesimulator/flac.framework/Versions/A/flac


# The FLACiOS project doesn't build a framework that works in the simulator (missing architectures i386 and x86_64)
rm -rf framework-iphonesimulator

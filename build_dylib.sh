#!/usr/bin/env bash

echo "Cleaning up..."
rm -rf bin/ src/
# rm -rf bin/ src/ FLEX/

# echo "Clonning sources..."
# git clone --recursive https://github.com/Flipboard/FLEX.git

echo "Updating FLEX submodule..."
git submodule foreach git pull origin master

echo "Copying sources..."
mkdir src/
find FLEX/Classes -type f \( -name "*.h" -o -name "*.m" \) -exec cp {} src/ \;

# NOTE
# This step is optional
# See: Module Initializers and Finalizers
# https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/DynamicLibraryDesignGuidelines.html

echo "Copying DKFLEXLoader..."
cp DKFLEXLoader/{DKFLEXLoader.h,DKFLEXLoader.m} src/

DYLIB_NAME="libFLEX"
BIN_NAME="${DYLIB_NAME}.dylib"
IOS_VERSION_MIN=7.0

# DEVELOPER_DIR="$(xcode-select --path)"
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
SDK_ROOT_OS=$DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
SDK_ROOT_SIMULATOR=$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk

ARCHS="armv7 arm64"

INPUT=$(find src -type f -name "*.m")

for ARCH in ${ARCHS}
do
	DIR=bin/${ARCH}
	mkdir -p ${DIR}
	echo "Building for ${ARCH}..."
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		SDK_ROOT=${SDK_ROOT_SIMULATOR}
		IOS_VERSION_MIN_FLAG=-mios-simulator-version-min
	else
		SDK_ROOT=${SDK_ROOT_OS}
		IOS_VERSION_MIN_FLAG=-mios-version-min
	fi
		FRAMEWORKS=${SDK_ROOT}/System/Library/Frameworks/
		INCLUDES=${SDK_ROOT}/usr/include/
		LIBRARIES=${SDK_ROOT}/usr/lib/
		# LIBRARIES=/usr/lib/

		# clang -I${INCLUDES} -F${FRAMEWORKS} -L${LIBRARIES} -Os -dynamiclib -isysroot ${SDK_ROOT} -arch ${ARCH} -fobjc-arc ${IOS_VERSION_MIN_FLAG}=${IOS_VERSION_MIN} -framework Foundation -framework UIKit -framework CoreGraphics -framework QuartzCore -framework ImageIO -lz -lsqlite3 -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations ${INPUT} -o ${DIR}/${BIN_NAME}
		
		clang -I${INCLUDES} -F${FRAMEWORKS} -L${LIBRARIES} -Os -dynamiclib -isysroot ${SDK_ROOT} -arch ${ARCH} -fobjc-arc ${IOS_VERSION_MIN_FLAG}=${IOS_VERSION_MIN} -framework Foundation -framework UIKit -framework CoreGraphics -framework QuartzCore -framework ImageIO -lz -lsqlite3 -fobjc-arc ${INPUT} -o ${DIR}/${BIN_NAME}
done

echo "Creating universal (armv7 & arm64) binary..."
FAT_BIN_DIR="bin/universal"
mkdir -p ${FAT_BIN_DIR}
lipo -create bin/**/${BIN_NAME} -output ${FAT_BIN_DIR}/${BIN_NAME}

echo "Codesigning with 'THEOS' self-signed certificate"
codesign -fs 'THEOS' ${FAT_BIN_DIR}/${BIN_NAME}

echo "Clean up src/..."
rm -rf src/

echo "Copying to layout/Library/MobileSubstrate/DynamicLibraries"
mkdir -p layout/Library/MobileSubstrate/DynamicLibraries
yes | cp -rf ${FAT_BIN_DIR}/${BIN_NAME} layout/Library/MobileSubstrate/DynamicLibraries

echo "Making ${DYLIB_NAME}'s .plist file'"
if [ ! -f layout/Library/MobileSubstrate/DynamicLibraries/${DYLIB_NAME}.plist ]; then
	cat > layout/Library/MobileSubstrate/DynamicLibraries/${DYLIB_NAME}.plist << EOF
	{ Filter = { Bundles = ( "com.apple.UIKit" ); }; }
EOF
fi
echo "Done."

#!/bin/bash

set -e

clang_version=$(clang --version | python3 -c "import sys, re; print(re.findall(r'clang-([0-9.]+)', sys.stdin.read())[0])")
CLANG_XCODE12_BETA3="1200.0.26.2"
CLANG_XCODE12_3_RC="1200.0.32.28"
CLANG_XCODE13="1300.0.0.0"
need_workaround=$(python3 -c "vtuple = lambda ver: tuple(map(int, ver.split('.'))); print(int(vtuple('$CLANG_XCODE12_BETA3') <= vtuple('$clang_version') < vtuple('$CLANG_XCODE13')))")

if [[ $need_workaround -ne 1 ]]; then
  carthage "$@"
  exit 0
fi

echo "Applying Carthage build workaround to exclude Apple Silicon binaries. See https://github.com/Carthage/Carthage/issues/3019 for more details"

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

# For Xcode 12 (beta 3+) make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

need_workaround_supported_version=$(python3 -c "vtuple = lambda ver: tuple(map(int, ver.split('.'))); print(int(vtuple('$CLANG_XCODE12_3_RC') <= vtuple('$clang_version') < vtuple('$CLANG_XCODE13')))")
if ! [[ $need_workaround_supported_version -ne 1 ]]; then
  # For Xcode 12.3+
  # simulators
  echo 'SUPPORTED_PLATFORMS = iphonesimulator' >> $xcconfig
  # real devices
  # echo 'SUPPORTED_PLATFORMS = iphoneos' >> $xcconfig
fi

#XCODE_XCCONFIG_FILE="$xcconfig" carthage "$@"

# carthage checkout
# carthage build # with each SUPPORTED_PLATFORMS and each project. Should specify scheme...

# simulator
# /usr/bin/xcrun xcodebuild -project /Users/kazuaki/GitHub/WebDriverAgent/Carthage/Checkouts/CocoaAsyncSocket/CocoaAsyncSocket.xcodeproj -scheme iOS\ Framework -configuration Release -derivedDataPath /Users/kazuaki/Library/Caches/org.carthage.CarthageKit/DerivedData/12.3_12C33/CocoaAsyncSocket/72e0fa9e62d56e5bbb3f67e9cfd5aa85841735bc -sdk iphonesimulator -destination platform=iOS\ Simulator,id=51CDCB06-1EB6-40FF-A450-CE378127874A -destination-timeout 3 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES build
# /usr/bin/xcrun xcodebuild -project /Users/kazuaki/GitHub/WebDriverAgent/Carthage/Checkouts/YYCache/Framework/YYCache.xcodeproj -scheme YYCache\ iOS -configuration Release -derivedDataPath /Users/kazuaki/Library/Caches/org.carthage.CarthageKit/DerivedData/12.3_12C33/YYCache/1.1.2 -sdk iphonesimulator -destination platform=iOS\ Simulator,id=51CDCB06-1EB6-40FF-A450-CE378127874A -destination-timeout 3 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES build


# real device
 /usr/bin/xcrun xcodebuild -project /Users/kazuaki/GitHub/WebDriverAgent/Carthage/Checkouts/CocoaAsyncSocket/CocoaAsyncSocket.xcodeproj -scheme Mac\ Framework -configuration Release -derivedDataPath /Users/kazuaki/Library/Caches/org.carthage.CarthageKit/DerivedData/12.3_12C33/CocoaAsyncSocket/72e0fa9e62d56e5bbb3f67e9cfd5aa85841735bc ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES archive -archivePath /var/folders/y6/524wp8fx0xj5q1rf6fktjrb00000gn/T/CocoaAsyncSocket SKIP_INSTALL=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=NO CLANG_ENABLE_CODE_COVERAGE=NO STRIP_INSTALLED_PRODUCT=NO
/usr/bin/xcrun xcodebuild -project /Users/kazuaki/GitHub/WebDriverAgent/Carthage/Checkouts/YYCache/Framework/YYCache.xcodeproj -scheme YYCache\ iOS -configuration Release -derivedDataPath /Users/kazuaki/Library/Caches/org.carthage.CarthageKit/DerivedData/12.3_12C33/YYCache/1.1.2 -sdk iphoneos ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES archive -archivePath /var/folders/y6/524wp8fx0xj5q1rf6fktjrb00000gn/T/YYCache SKIP_INSTALL=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=NO CLANG_ENABLE_CODE_COVERAGE=NO STRIP_INSTALLED_PRODUCT=NO

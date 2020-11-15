### Runs either a format or lint run of SwiftFormat

set -e

# The header of each Swift file (should match format set in .xcodeproj/xcshareddata/IDETemplateMacros.plist)
HEADER_FORMAT="{file}\nCopyright (c) {year} Dylan Gattey"

# If you want to overwrite all files, set SWIFT_FORMAT_OVERWRITE to something, otherwise it uses lenient linting
#SWIFT_FORMAT_OVERWRITE="YES"
if [[ -n $SWIFT_FORMAT_OVERWRITE ]]; then
    SFARGS=""
else
    SFARGS="--lint --lenient"
fi

cd $SRCROOT/../buildTools
echo "IF THIS IS TAKING FOREVER - it's probably installing SwiftFormat as a package"
echo "Running on all files in $SRCROOT..."
swift run -c release swiftformat --swiftversion "$SWIFT_VERSION" "$SRCROOT" --header "$HEADER_FORMAT" $SFARGS

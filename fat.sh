# Builds a fat library for a given xcode project (framework)

IOS_SDK_VERSION="14.5" # xcodebuild -showsdks
SWIFT_PROJECT_NAME="YMChat"
SWIFT_PROJECT_PATH="$SWIFT_PROJECT_NAME.xcodeproj"
SWIFT_BUILD_PATH="build"
SWIFT_OUTPUT_PATH="build/swift-framework-proxy"
XAMARIN_BINDING_PATH="/Users/kaunteysuryawanshi/xama/Binder1/Binder1"

echo "Remove build/ folder"
rm -Rf "$SWIFT_BUILD_PATH"

echo "Build iOS framework for simulator"
xcodebuild -sdk iphonesimulator$IOS_SDK_VERSION -project "$SWIFT_PROJECT_PATH" -configuration Release -quiet

echo "Build iOS framework for device"
xcodebuild -sdk iphoneos$IOS_SDK_VERSION -project "$SWIFT_PROJECT_PATH" -configuration Release -quiet

echo "Copy one build as a fat framework"
cp -R "$SWIFT_BUILD_PATH/Release-iphoneos" "$SWIFT_BUILD_PATH/Release-fat"

echo "Combine modules from another build with the fat framework modules"
cp -R \
    "$SWIFT_BUILD_PATH/Release-iphonesimulator/$SWIFT_PROJECT_NAME.framework/Modules/$SWIFT_PROJECT_NAME.swiftmodule/" \
    "$SWIFT_BUILD_PATH/Release-fat/$SWIFT_PROJECT_NAME.framework/Modules/$SWIFT_PROJECT_NAME.swiftmodule/"

echo "Remove the 'arm64' architecture from the simulator"
lipo -remove arm64 "$SWIFT_BUILD_PATH/Release-iphonesimulator/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME"\
 -output "$SWIFT_BUILD_PATH/Release-iphonesimulator/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME"

echo "Combine iphoneos + iphonesimulator configuration as fat libraries"
lipo -create -output "$SWIFT_BUILD_PATH/Release-fat/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME" \
    "$SWIFT_BUILD_PATH/Release-iphoneos/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME" \
    "$SWIFT_BUILD_PATH/Release-iphonesimulator/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME"

echo "Verify results"
lipo -info "$SWIFT_BUILD_PATH/Release-fat/$SWIFT_PROJECT_NAME.framework/$SWIFT_PROJECT_NAME"

echo "Copy fat frameworks to the output folder"
rm -Rf "$SWIFT_OUTPUT_PATH"
mkdir "$SWIFT_OUTPUT_PATH"
cp -Rf "$SWIFT_BUILD_PATH/Release-fat/$SWIFT_PROJECT_NAME.framework" "$SWIFT_OUTPUT_PATH"

echo "Generating binding api definition and structs"
sharpie bind \
    --sdk=iphoneos$IOS_SDK_VERSION \
    --output="$SWIFT_OUTPUT_PATH/XamarinApiDef" \
    --namespace="Binding" \
    --scope="$SWIFT_OUTPUT_PATH/$SWIFT_PROJECT_NAME.framework/Headers/" \
    "$SWIFT_OUTPUT_PATH/$SWIFT_PROJECT_NAME.framework/Headers/$SWIFT_PROJECT_NAME-Swift.h"

echo "Replace existing metadata with the udpated"
# cp -Rf "$SWIFT_OUTPUT_PATH/XamarinApiDef/." "$XAMARIN_BINDING_PATH/"
cp -Rf "$SWIFT_OUTPUT_PATH/XamarinApiDef/ApiDefinitions.cs" "$XAMARIN_BINDING_PATH/ApiDefinition.cs"

echo "Done!"

#!/bin/bash

FRAMEWORK_NAME="YMChat"

IOS_PATH="./build/archives/ios.xcarchive"
IOS_SIMULATOR_PATH="./build/archives/ios_sim.xcarchive"

rm -rf build/

xcodebuild archive -scheme ${FRAMEWORK_NAME} -archivePath ${IOS_PATH} -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -archivePath ${IOS_SIMULATOR_PATH} -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework ${IOS_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
  -framework ${IOS_SIMULATOR_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
  -output "./build/${FRAMEWORK_NAME}.xcframework"

pushd build
zip -vry ${FRAMEWORK_NAME}.xcframework.zip ${FRAMEWORK_NAME}.xcframework/ -x "*.DS_Store"
popd

fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios fat
```
fastlane ios fat
```
Creates xcframework using carthage and its zip file
### ios build_framework
```
fastlane ios build_framework
```
Creates xcframework using carthage and its zip file
### ios valid_version
```
fastlane ios valid_version
```
Check if the new version is already used in the files
### ios release
```
fastlane ios release
```
Creates release using the version passed

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

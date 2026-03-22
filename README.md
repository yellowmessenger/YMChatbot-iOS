# YMChat

## Documentation
For integration and usage refer documentation [https://docs.yellow.ai/docs/platform_concepts/mobile/chatbot/ios](https://docs.yellow.ai/docs/platform_concepts/mobile/chatbot/ios)

## Example App
A minimal example app is included in the `Example/` directory. To run it:
1. Open `Example/YMChatExample.xcodeproj` in Xcode
2. Replace `YOUR_BOT_ID` in `ViewController.swift` with your bot ID
3. Build and run

The example app imports YMChat as a local SPM package. Alternatively, you can use CocoaPods:
```bash
cd Example && pod install
```
Then open `YMChatExample.xcworkspace` instead.

> **Note:** The `Example/` directory is excluded from CocoaPods and SPM distribution — it is only available when cloning the repo directly.

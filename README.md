# YMChat
- [Installation](#installation)
- [Usage](#usage)

## Installation
### CocoaPods
To integrate YMChatbot into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'YMChat'
```
  
## Usage
### Basic
Import the YMChat framework in Swift file
```swift
import YMChat
```

After the framework is imported the basic bot can be presented with few lines as below 
```swift
let config = YMConfig(botId: "x1234567890")
YMChat.shared.config = config
YMChat.shared.presentView(on: self)
```

### YMConfig
YMConfig configures chatbot before it presented on the screen. It is recommended to set appropriate config before presenting the bot

#### Initialize
YMConfig requires botID to initialize. All other settings can be changed after config has been initialised
```swift
let config = YMConfig(botId: "x1234567890")
```

#### Speech to Text
Speech to text can be enabled by setting the enableSpeech flag present in config. Default value is `false`
```swift
config.enableSpeech = true
```

If you are adding Speech recognization, add following snippet to Info.plist of the host app
```xml
<key>NSMicrophoneUsageDescription</key>  
<string>Your microphone will be used to record your speech when you use the Voice feature.</string>
<key>NSSpeechRecognitionUsageDescription</key>  
<string>Speech recognition will be used to determine which words you speak into this device&apos;s microphone.</string>
```

#### Payload
Additional payload can be added in the form of key value pair, which is then appended to the bot
```swift
config.payload = ["name": "ym.bot.name", "device-type": "mobile"]
```

#### History
Chat history can be enabled by setting the `enableHistory` flag present in YMConfig. Default value is `false`
```swift
config.enableHistory = true
```

### Present chatbot
Chat bot can be presented by calling `startChatbot()` and passing your view controller as an argument
```swift
YMChat.shared.startChatbot(on: self) // self is the current view controller
YMChat.shared.startChatbot()
```

Chat view can also be presented without parameter
```swift
YMChat.shared.startChatbot()
```
Note: When presentView is invoked with no parameter then the view controller is fetched using `UIApplication.shared.windows.last?.rootViewController`

### Close bot
Bot can be programatically closed using `closeBot()` function
```swift
YMChat.shared.closeBot()
```

### Event from bot
Events from bot can be handled using delegate pattern.

```swift
YMChat.shared.delegate = self
```

Once the delegate is assigned define the `eventResponse(_:)` function

```swift
func eventResponse(_ response: YMBotEventResponse) {
    print("Event received \(response)")
    if response.code == "example-code" {
        // Your logic
    }
}
```

## Custom URL configuration (for on premise deployments)
Base url for the bot can be customized by setting `config.customBaseUrl` parameter. Use the same url used for on-prem deployment.

```swift
config.customBaseUrl = "<custom_url>"
```

### Logging
Logging can be enabled to understand the code flow and to fix bugs. It can be enabled from config
```swift
YMChat.shared.enableLogging = true
```

## Demo App
A demo has been created to better understand the integration of SDK in iOS app
[https://github.com/yellowmessenger/YMChatbot-iOS-DemoApp](https://github.com/yellowmessenger/YMChatbot-iOS-DemoApp)

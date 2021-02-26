# YMChat
- [Installation](#installation)
- [Usage](#usage)

# Installation
## CocoaPods
To integrate YMChatbot into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'YMChat'
```
  
# Usage
## Basic
Import the YMChat framework in Swift file
```
import YMChat
```

After the framework is imported the basic bot can be presented with few lines as below 
```
let config = YMConfig(botId: "x1234567890")
YMChat.shared.config = config
YMChat.shared.presentView(on: self)
```

## YMConfig
YMConfig configures chatbot before it presented on the screen. It is recommended to set appropriate config before presenting the bot

### Initialize
YMConfig requires botID to initialize. All other settings can be changed after config has been initialised
```
let config = YMConfig(botId: "x1234567890")
```

### Speech to Text
Speech to text can be enabled by setting the enableSpeech flag present in config. Default value is `false`
```
config.enableSpeech = true
```

### Payload
Additional payload can be added in the form of key value pair, which is then appended to the bot
```
config.payload = ["name": "ym.bot.name", "device-type": "mobile"]
```

### History
Chat history can be enabled by setting the `enableHistory` flag present in YMConfig. Default value is `false`
```
config.enableHistory = true
```

## Present chatbot
Chat bot can be presented by calling `startChatbot()` and passing your view controller as an argument
```
YMChat.shared.startChatbot(on: self) // self is the current view controller
YMChat.shared.startChatbot()
```

Chat view can also be presented without parameter
```
YMChat.shared.startChatbot()
```
Note: When presentView is invoked with no parameter then the view controller is fetched using `UIApplication.shared.windows.last?.rootViewController`

## Close bot
Bot can be programatically closed using `closeBot()` function
```
YMChat.shared.closeBot()
```

## Event from bot
Events from bot can be handled using delegate pattern.

```
YMChat.shared.delegate = self
```

Once the delegate is assigned define the `eventResponse(_:)` function

```
func eventResponse(_ response: YMBotEventResponse) {
    print("Event received \(response)")
    if response.code == "example-code" {
        // Your logic
    }
}
```

## Logging
Logging can be enabled to understand the code flow and to fix bugs. It can be enabled from config
```
YMChat.shared.enableLogging = true
```

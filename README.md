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

Chatbot can be presented with very few steps 
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

## Show chatbot
Chat view can be presented on an existing view controller.
```
let config = YMConfig(botId: "x1234567890")
YMChat.shared.presentView(on: self)
```
`presentView` function takes the view controller as a parameter that would present the Chat bot

## Event from bot
```
YMChat.shared.onEventFromBot = { response in
    print("Event received \(response)")
    if response.code == "login-user" {
        // Login
    }
}
```

Or, a function can be defined and then assigned for code modularity
```
func eventResponse(_ response: YMBotEventResponse) {
    print("Event received \(response)")
    if response.code == "login-user" {
        //Login
    }
}

YMChat.shared.onEventFromBot = eventResponse(_:)
```

## Logging
Logging can be enabled to understand the code flow and to fix bugs. It can be enabled from config
```
YMChat.shared.enableLogging = true
```

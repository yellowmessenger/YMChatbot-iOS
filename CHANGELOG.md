# Change Log

All notable changes to this project will be documented in this file.

-----

## [v1.27.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.27.1) (2026-05-01)

#### Bug Fix 🐛
* Fixed `statusBarColor` incorrectly coloring the entire view background; it now applies only to a dedicated view covering the top safe area above the WebView.

---

## [v1.27.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.27.0) (2026-04-30)

#### New Update 🚀
* `input-background-color` event now only updates the view background when `statusBarColor` is `.white`; custom host-app colors are no longer overridden by the bot.

---

## [v1.26.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.26.0) (2026-04-23)

#### New Update 🚀
* Added support for sending state events to the bot.
* Handle `window.open` links inside the WebView and delegate URL clicks to the host app.

---

## [v1.25.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.25.0) (2025-07-30)

#### New Update 🚀
* Close button visibility managed while bot is rendering
* Safe area color as per the bot theme 

---

## [v1.24.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.24.0) (2025-04-10)

#### New Update 🚀
* added `onBotLoadFailed` method in YMChatDelegate to let user know that bot load failed due to certain technical issue.

---

## [v1.23.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.23.0) (2025-04-07)

#### New Update 🚀
* added support for `linkColor` in theme variable.

---

## [v1.22.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.22.1) (2025-04-03)

#### New Update 🚀
* Added an option that prevents links from opening in the browser. Set `shouldOpenLinkExternally` to false in config to prevent opening url in new window, and listen to `url-clicked` event in `onEventFromBot` to get the url of the link clicked.

---

## [v1.21.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.21.1) (2024-10-23)

#### Bug Fix 🐛 
* added support for older `enableSpeechConfig` variable but marked as unavailable.

---

## [v1.21.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.21.0) (2024-10-21)

#### New Update 🚀
* updated `YMEnableSpeechConfig` to enable speech and added option to make floating mic button static

---

## [v1.20.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.20.0) (2024-09-30)

#### Bug Fix 🐛 
* deinitialize `YMChatViewController` on tap of bot close button

---

## [v1.19.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.19.0) (2024-09-18)

#### New Update 🚀
* Added `chatBotTheme` in YMTheme model to set theme for chat conatiner

---

## [v1.18.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.18.1) (2024-07-29)

#### Bug Fix 🐛 
* Email placeholder updated in html file

---

## [v1.18.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.18.0) (2024-05-14)

#### New Update 🚀
* Added `botBubbleBackgroundColor` in YMTheme model to add background color for bot bubble

---

## [v1.17.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.17.0) (2024-03-28)

#### New Feature 🚀
* Privacy manifest file added.

---

## [v1.16.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.16.0) (2023-12-22)

#### New Feature 🚀
* Passing App Ids for App Whitelisting feature

---

## [v1.15.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.15.0) (2023-11-22)

#### New Feature 🚀
* Exposing a theme variable in config to set bot name, description, icon image, primary and secondary color and others.

---

## [v1.14.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.14.1) (2023-09-12)

#### New Feature 🚀
* Exposing a controlled API (`sendEventToBot(model)`) for sending event to bot

---

## [v1.14.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.14.0) (2023-09-12)

#### New Feature 🚀
* Exposing a controlled API (`sendEventToBot(model)`) for sending event to bot

---

## [v1.13.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.13.0) (2023-09-08)

#### New Feature 🚀
* Added support for secure YMAuth

---

## [v1.12.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.12.0) (2023-07-10)

#### New Feature 🚀
* Added Foreground & Background Event when app goes in background or foreground

---

## [v1.11.2](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.11.2) (2023-07-04)

#### Bug Fix 🐛
* Console log removed from html file.

---

## [v1.11.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.11.1) (2023-06-30)

#### New Feature 🚀
* Updated Unlink Device Token API

---

## [v1.11.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.11.0) (2023-05-19)

#### New Feature 🚀
* Floating Mic Button added

---

## [v1.10.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.10.1) (2023-03-23)

#### Bug Fix 🐛
* Mic button issue fixed.

---

## [v1.10.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.10.0) (2023-03-21)

#### New Feature 🚀
* reloadBot API added.

---

## [v1.9.4](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.9.4) (2023-03-11)

#### Bug Fix 🐛
* Fixed `closeBot` issue

---

## [v1.9.3](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.9.3) (2023-02-06)

#### Bug Fix 🐛
* Resolved SPM Distributon Issue

---

## [v1.9.2](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.9.2) (2023-01-25)

#### Bug Fix 🐛
* Renamed **html file** to avoid conflict with other libs

---

## [v1.9.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.9.1) (2022-11-25)

#### Bug Fix 🐛
* Fixed `customBaseUrl` support for v1 bot

-----

## [v1.9.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.9.0) (2022-09-23)

#### Feature 🚀
Added Public APIs 
- `getUnreadMessageCount`
- `registerDevice`
- `unlinkDeviceToken`

-----

## [v1.8.4](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.8.4) (2022-09-13)

#### Bug Fix 🐛
* Fixed `customLoaderUrl` support for lite version

-----

## [v1.8.3](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.8.3) (2022-09-06)

#### Bug Fix 🐛
* Fixed Package issue for custom loader

-----

## [v1.8.2](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.8.2) (2022-09-06)

#### Feature 🚀
* Added `useLiteVersion` support.

-----

## [v1.8.1](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.8.1) (2022-08-09)

#### Feature 🚀
* Added `disableActionsOnLoad` support.

-----

## [v1.8.0](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.8.0) (2022-07-08)

#### Bug Fix 🐛
* API Key issue for unlink device token fixed

-----

## [v1.7.8](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.7.8) (2022-06-07)

#### Bug Fix 🐛
* **FIXED:** For iOS device file exceed limitation message not displayed when customer upload more than 20 mb document

-----

## [v1.7.7](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.7.7) (2022-05-27)

#### Bug Fix 🐛
* **FIXED:** Speech Permission Issue

-----

## [v1.7.5](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.7.5) (2022-05-17)

#### Bug Fix 🐛
* **FIXED:** Not getting close bot events

-----

## [v1.7.3](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/1.7.3) (2022-01-17)

#### Feature 🚀
* Added SPM support.

---


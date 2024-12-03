# Example Apps

This folder contains three example apps that demonstrate how to use the Friendly Captcha SDK for iOS. Each renders a simple login screen that uses Friendly Captcha to protect against bots. The apps showcase how to integrate using various iOS development languages and UI frameworks.

| Xcode Scheme | UI Framework | Language | Integration Example |
| ------------ | ------------ | -------- | ---- |
| Example_UIKit | UIKit | Swift | [ViewController.swift](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/UIKit/ViewController.swift) |
| Example_ObjC | UIKit | Objective-C | [ViewController.m](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/ObjectiveC/ViewController.m) |
| Example_SwiftUI | SwiftUI | Swift | [ContentView.swift](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/SwiftUI/ContentView.swift) |

To run an example app in Xcode, clone the repo, and run `pod install` from the Example directory first. Then, start Xcode and, when prompted to open an existing project, open the xcworkspace located at `Example/FriendlyCaptcha.xcworkspace`. Make sure the desired example app scheme is selected, along with an iOS Simulator:

![Xcode scheme and destination selector](https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/xcode-top-bar.png)

Xcode can be finicky; sometimes closing and restarting it can clear reported errors.

## Server

For a fully functional, end-to-end example, you'll also need to run the server that handles the back-end validation logic. Instructions for running the server can be found in the [`server`](https://github.com/FriendlyCaptcha/friendly-captcha-ios/tree/main/Example/server) directory.

Note that you'll need to replace the `sitekey` that comes with the examples with the one you create for use with this server. That example `sitekey` can be found in the above-mentioned files. Search for the string "FC" in each of those files.

## License

All example code is licensed under the open source MIT License. See the [LICENSE](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/LICENSE) file for details.

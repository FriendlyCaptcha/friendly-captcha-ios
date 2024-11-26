# Friendly Captcha iOS SDK

The Friendly Captcha iOS SDK allows you to easily integrate [Friendly Captcha](https://friendlycaptcha.com) into your iOS applications.

>This SDK is for **Friendly Captcha v2**.

## Installation

This SDK is available via CocoaPods and Carthage. You can find the latest version number on the [Releases](https://github.com/FriendlyCaptcha/friendly-captcha-ios/releases) page.

### CocoaPods

Add the following line to your Podfile:

```
pod 'FriendlyCaptcha'
```

You can also specify a particular version. See the [CocoaPods documentation](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions) for guidance.

### Carthage

TODO

## Documentation

The full API reference for the SDK is available [here](https://friendlycaptcha.github.io/friendly-captcha-ios/documentation/friendlycaptcha).

## Supported Platforms

This SDK has been successfully built and run targeting **iOS 10**, but theoretically it should support as far back as **iOS 8**. Due to tooling constraints, support for versions earlier than iOS 10 is on a best effort basis.

## Example

This repository contains 3 minimal example apps to show how to integrate Friendly Captcha.

| Xcode Scheme | UI Framework | Language | Path |
| ------------ | ------------ | -------- | ---- |
| Example_UIKit | UIKit | Swift | `Example/UIKit` |
| Example_ObjC | UIKit | Objective-C | `Example/ObjectiveC` |
| Example_SwiftUI | SwiftUI | Swift | `Example/SwiftUI` |

To run an example app in Xcode, clone the repo, and run `pod install` from the Example directory first. Then, start Xcode and, when prompted to open an existing project, open the xcworkspace located at `Example/FriendlyCaptcha.xcworkspace`. Make sure the desired example app scheme is selected, along with an iOS Simulator:

![Xcode scheme and destination selector](./screenshots/xcode-top-bar.png)

Xcode can be finicky; sometimes closing and restarting it can clear reported errors.

## License

This is free software; you can redistribute it and/or modify it under the terms of the [Mozilla Public License Version 2.0](./FriendlyCaptcha/LICENSE).

All examples are released under the [MIT license](./Example/LICENSE).

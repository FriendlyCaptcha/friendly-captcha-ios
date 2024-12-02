# Friendly Captcha iOS SDK
[![Cocoapods Version](https://img.shields.io/cocoapods/v/FriendlyCaptcha)](https://cocoapods.org/pods/FriendlyCaptcha) [![Cocoapods Platforms](https://img.shields.io/cocoapods/p/FriendlyCaptcha)](https://cocoapods.org/pods/FriendlyCaptcha) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The Friendly Captcha iOS SDK allows you to easily integrate [Friendly Captcha](https://friendlycaptcha.com) into your iOS applications.

>This SDK is for **Friendly Captcha v2**.

## Installation

This SDK is available via CocoaPods and Carthage. You can find the latest version number on the [Releases](https://github.com/FriendlyCaptcha/friendly-captcha-ios/releases) page.

### CocoaPods

Add the following line to your Podfile:

```
pod 'FriendlyCaptcha', '~> 0.1.3'
```

### Carthage

Add the following line to your Cartfile:

```
github "FriendlyCaptcha/friendly-captcha-ios" ~> 0.1.3
```

## Documentation

The full API reference for the SDK is available [here](https://friendlycaptcha.github.io/friendly-captcha-ios/documentation/friendlycaptcha).

## Supported Platforms

This SDK has been successfully built and run targeting **iOS 10**. On CocoaPods, it has been successfully packaged with a minimum target of **iOS 9**. Theoretically, it should be fully functional as far back as **iOS 8**, but due to tooling constraints, support for versions earlier than iOS is offered on a "best effort" basis.

If you have trouble with the above installation methods, it should be possible to simply copy [the Swift files in `FriendlyCaptcha/Classes`](https://github.com/FriendlyCaptcha/friendly-captcha-ios/tree/main/FriendlyCaptcha/Classes) into your (>= iOS 8) project.

## Usage

This repository contains 3 minimal example apps to show how to integrate Friendly Captcha.

| Xcode Scheme | UI Framework | Language | Integration Example |
| ------------ | ------------ | -------- | ---- |
| Example_UIKit | UIKit | Swift | [ViewController.swift](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/UIKit/ViewController.swift) |
| Example_ObjC | UIKit | Objective-C | [ViewController.m](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/ObjectiveC/ViewController.m) |
| Example_SwiftUI | SwiftUI | Swift | [ContentView.swift](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/SwiftUI/ContentView.swift) |

To run an example app in Xcode, clone the repo, and run `pod install` from the Example directory first. Then, start Xcode and, when prompted to open an existing project, open the xcworkspace located at `Example/FriendlyCaptcha.xcworkspace`. Make sure the desired example app scheme is selected, along with an iOS Simulator:

![Xcode scheme and destination selector](https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/xcode-top-bar.png)

Xcode can be finicky; sometimes closing and restarting it can clear reported errors.

## Screenshots

<p float="left">
  <img width="45%" alt="An example disabled login page with Friendly Captcha" src="https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/disabled.png" />
  <img width="45%" alt="An example enabled login page with Friendly Captcha" src="https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/enabled.png" />
</p>

## License

This is free software; you can redistribute it and/or modify it under the terms of the [Mozilla Public License Version 2.0](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/LICENSE).

All examples are released under the [MIT license](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/FriendlyCaptcha/LICENSE).

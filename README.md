# Friendly Captcha iOS SDK
[![Cocoapods Version](https://img.shields.io/cocoapods/v/FriendlyCaptcha)](https://cocoapods.org/pods/FriendlyCaptcha) [![Cocoapods Platforms](https://img.shields.io/cocoapods/p/FriendlyCaptcha)](https://cocoapods.org/pods/FriendlyCaptcha) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The Friendly Captcha iOS SDK allows you to easily integrate [Friendly Captcha](https://friendlycaptcha.com) into your iOS applications.

>This SDK is for **Friendly Captcha v2**.

## Installation

This SDK is available via CocoaPods and Carthage. You can find the latest version number on the [Releases](https://github.com/FriendlyCaptcha/friendly-captcha-ios/releases) page.

### SPM

Add the following to the list of dependencies in your `Package.swift`:

```
.package(
    url: "https://github.com/FriendlyCaptcha/friendly-captcha-ios.git",
    .upToNextMinor(from: "1.0.1")
)
```

### Carthage

Add the following line to your `Cartfile`:

```
github "FriendlyCaptcha/friendly-captcha-ios" ~> 1.0.1
```

### CocoaPods

Add the following line to your `Podfile`:

```
pod 'FriendlyCaptcha', '~> 1.0.1'
```

## Documentation

The full API reference for the SDK is available [here](https://friendlycaptcha.github.io/friendly-captcha-ios/documentation/friendlycaptcha).

## Supported Platforms

This SDK has been successfully built and run targeting **iOS 10**. On CocoaPods, it has been successfully packaged with a minimum target of **iOS 9**. Theoretically, it should be fully functional as far back as **iOS 8**, but due to tooling constraints, support for versions earlier than iOS is offered on a "best effort" basis.

If you have trouble with the above installation methods, it should be possible to simply copy [the Swift files in `FriendlyCaptcha/Classes`](https://github.com/FriendlyCaptcha/friendly-captcha-ios/tree/main/FriendlyCaptcha/Classes) into your (>= iOS 8) project.

## Usage

This repository contains 3 minimal example apps to show how to integrate Friendly Captcha. For more information, including about how to run them locally, see [the README in the Example folder](https://github.com/FriendlyCaptcha/friendly-captcha-ios/tree/main/Example).

### Testing

Tests for the SDK are located [in the `Example` directory](https://github.com/FriendlyCaptcha/friendly-captcha-ios/tree/main/Example/Tests). This appears to be [an artifact of how CocoaPods structures a library](https://github.com/CocoaPods/CocoaPods/issues/4755#issuecomment-170940549).

If running the tests in Xcode, make sure that the `Example_UIKit` scheme is selected. You can also run the tests from the command line:

```
xcodebuild \
  -workspace Example/FriendlyCaptcha.xcworkspace \
  -scheme Example_UIKit \
  test \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'
```

Depending on which simulators you have installed, you may need to change the version numbers in the `-destination` argument. You can pipe the output into [`xcbeautify`](https://github.com/cpisciotta/xcbeautify), if it's available.

## Screenshots

<p float="left">
  <img width="45%" alt="An example disabled login page with Friendly Captcha" src="https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/disabled.png" />
  <img width="45%" alt="An example enabled login page with Friendly Captcha" src="https://raw.githubusercontent.com/FriendlyCaptcha/friendly-captcha-ios/main/screenshots/enabled.png" />
</p>

## License

This is free software; you can redistribute it and/or modify it under the terms of the [Mozilla Public License Version 2.0](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/Example/LICENSE).

All examples are released under the [MIT license](https://github.com/FriendlyCaptcha/friendly-captcha-ios/blob/main/FriendlyCaptcha/LICENSE).

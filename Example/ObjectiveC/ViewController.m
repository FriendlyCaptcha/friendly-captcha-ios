//
//  ViewController.m
//  Example_ObjC
//
//  Created by Aaron Greenberg on 11/25/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@import FriendlyCaptcha;

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIView *captchaContainer;
@property (nonatomic, strong) FriendlyCaptcha *handle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupFriendlyCaptcha];
}

- (UITextField *)usernameTextField {
    if (!_usernameTextField) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.placeholder = @"Username";
        _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordTextField;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_registerButton setTitle:@"Register" forState:UIControlStateNormal];
        _registerButton.backgroundColor = [UIColor grayColor];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerButton.layer.cornerRadius = 5;

        // 1. The form submission button starts out disabled.
        _registerButton.enabled = NO;
        _registerButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _registerButton;
}

// A UIView is created to contain the FriendlyCaptcha Widget view.
- (UIView *)captchaContainer {
    if (!_captchaContainer) {
        _captchaContainer = [[UIView alloc] init];
        _captchaContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _captchaContainer;
}

- (FriendlyCaptcha *)handle {
    if (!_handle) {
        _handle = [[FriendlyCaptcha alloc] initWithSitekey:@"FCMKRFNE61OM0D4Q"];
    }
    return _handle;
}

// 2. When either the username field or the password field are focused,
// `handle.start()` is called, allowing the widget to start solving.
- (void)textFieldDidBeginEditing:(UITextField *)_ {
    [self.handle start];
}

- (void)setupUI {
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.captchaContainer];

    [NSLayoutConstraint activateConstraints:@[
        [self.usernameTextField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.usernameTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.usernameTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.passwordTextField.topAnchor constraintEqualToAnchor:self.usernameTextField.bottomAnchor constant:20],
        [self.passwordTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.passwordTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.captchaContainer.topAnchor constraintEqualToAnchor:self.passwordTextField.bottomAnchor constant:20],
        [self.captchaContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.captchaContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.captchaContainer.heightAnchor constraintEqualToConstant:70],

        [self.registerButton.topAnchor constraintEqualToAnchor:self.captchaContainer.bottomAnchor constant:20],
        [self.registerButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.registerButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.registerButton.heightAnchor constraintEqualToConstant:44],
    ]];

    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)setupFriendlyCaptcha {
    [self addChildViewController:self.handle.Widget];
    [self.captchaContainer addSubview:[self.handle.Widget view]];
    [self.handle.Widget view].translatesAutoresizingMaskIntoConstraints = NO;

    // After adding the FriendlyCaptcha Widget view to the container,
    // make sure to set its contraints to the bounds of the container.
    // Otherwise, it may not be visible.
    [NSLayoutConstraint activateConstraints:@[
        [[self.handle.Widget view].leadingAnchor constraintEqualToAnchor:self.captchaContainer.leadingAnchor],
        [[self.handle.Widget view].trailingAnchor constraintEqualToAnchor:self.captchaContainer.trailingAnchor],
        [[self.handle.Widget view].topAnchor constraintEqualToAnchor:self.captchaContainer.topAnchor],
        [[self.handle.Widget view].bottomAnchor constraintEqualToAnchor:self.captchaContainer.bottomAnchor],
    ]];

    [self.handle.Widget didMoveToParentViewController:self];

    __weak typeof(self) weakSelf = self;

    // 3. If the widget successfully completes, the button is enabled.
    [self.handle onComplete:^(WidgetCompleteEvent * _Nonnull __strong _) {
        weakSelf.registerButton.enabled = YES;
        weakSelf.registerButton.backgroundColor = [UIColor systemBlueColor];
    }];

    // 4. If the widget errors, the button is _still_ enabled. This
    // "fail open" approach prevents the scenario where all users are
    // blocked from submitting the form.
    [self.handle onError:^(WidgetErrorEvent * _Nonnull __strong _) {
        weakSelf.registerButton.enabled = NO;
        weakSelf.registerButton.backgroundColor = [UIColor grayColor];
    }];

    // 5. If the widget expires, the button is disabled. The user will
    // need to restart the widget.
    [self.handle onExpire:^(WidgetExpireEvent * _Nonnull __strong _){
        weakSelf.registerButton.enabled = NO;
        weakSelf.registerButton.backgroundColor = [UIColor grayColor];
    }];
}

@end
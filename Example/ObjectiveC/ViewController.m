#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@import FriendlyCaptcha;

#define alwaysSuccess NO

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *loginTitleLabel;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *exampleCaptionLabel;
@property (nonatomic, strong) UIView *captchaContainer;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) FriendlyCaptcha *handle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupFriendlyCaptcha];
}

- (UILabel *)loginTitleLabel {
    if (!_loginTitleLabel) {
        _loginTitleLabel = [[UILabel alloc] init];
        _loginTitleLabel.text = @"Welcome";
        _loginTitleLabel.font = [UIFont boldSystemFontOfSize:24];
        _loginTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _loginTitleLabel;
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

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
    }
    return _stackView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loginButton setTitle:@"Log in" forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor grayColor];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 5;

        // 1. The form submission button starts out disabled.
        _loginButton.enabled = NO;
        _loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _loginButton;
}

- (UILabel *)exampleCaptionLabel {
    if (!_exampleCaptionLabel) {
        _exampleCaptionLabel = [[UILabel alloc] init];
        _exampleCaptionLabel.text = @"This is an example app.\nYou can enter any username or password.";
        _exampleCaptionLabel.font = [UIFont systemFontOfSize:14];
        _exampleCaptionLabel.textColor = [UIColor grayColor];
        _exampleCaptionLabel.numberOfLines = 0;
        _exampleCaptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _exampleCaptionLabel;
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
        _handle = [[FriendlyCaptcha alloc] initWithSitekey:@"FCMGD7SIQS6JUH0G"];
    }
    return _handle;
}

// 2. When either the username field or the password field are focused,
// `handle.start()` is called, allowing the widget to start solving.
- (void)textFieldDidBeginEditing:(UITextField *)_ {
    [self.handle start];
}

- (void)setupUI {
    [self.stackView addArrangedSubview:self.loginTitleLabel];
    [self.stackView addArrangedSubview:self.usernameTextField];
    [self.stackView addArrangedSubview:self.passwordTextField];
    [self.stackView addArrangedSubview:self.captchaContainer];
    [self.stackView addArrangedSubview:self.loginButton];
    [self.stackView addArrangedSubview:self.exampleCaptionLabel];

    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 15;
    self.stackView.alignment = UIStackViewAlignmentFill;
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.stackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.exampleCaptionLabel.topAnchor constraintEqualToAnchor:self.loginButton.bottomAnchor constant:10],
        [self.captchaContainer.heightAnchor constraintEqualToConstant:70],
        [self.loginButton.heightAnchor constraintEqualToConstant:44]
    ]];

    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
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
        weakSelf.loginButton.enabled = YES;
        weakSelf.loginButton.backgroundColor = [UIColor systemBlueColor];
    }];

    // 4. If the widget errors, the button is _still_ enabled. This
    // "fail open" approach prevents the scenario where all users are
    // blocked from submitting the form.
    [self.handle onError:^(WidgetErrorEvent * _Nonnull __strong _) {
        weakSelf.loginButton.enabled = NO;
        weakSelf.loginButton.backgroundColor = [UIColor grayColor];
    }];

    // 5. If the widget expires, the button is disabled. The user will
    // need to restart the widget.
    [self.handle onExpire:^(WidgetExpireEvent * _Nonnull __strong _){
        weakSelf.loginButton.enabled = NO;
        weakSelf.loginButton.backgroundColor = [UIColor grayColor];
    }];
}

// 6. When the captcha is done and the response available, it needs to
// be sent to the back-end for verification, along with any other
// server-side validation.
//
// See https://developer.friendlycaptcha.com/docs/v2/getting-started/verify
- (void)loginButtonTapped {
    if (alwaysSuccess) {
        [self showAlert:@"Always successful!" success:YES];
        return;
    }

    NSURL *url = [NSURL URLWithString:@"http://localhost:3600/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *loginData = @{
        @"username": self.usernameTextField.text ?: @"",
        @"password": self.passwordTextField.text ?: @"",
        @"frc-captcha-response": [self.handle getResponse]
    };

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:loginData options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Error serializing login data: %@", error);
        return;
    }

    [request setHTTPBody:jsonData];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
            return;
        }

        if (data) {
            NSError *jsonError;
            id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonResponse) {
                NSLog(@"Error parsing response: %@", jsonError);
                return;
            }

            if ([jsonResponse isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDict = (NSDictionary *)jsonResponse;
                NSString *message = responseDict[@"message"];
                BOOL success = [responseDict[@"success"] boolValue];

                [self showAlert:message success:success];
            }
        }
    }];

    [dataTask resume];
}

-(void)showAlert:(NSString *)message success:(BOOL)success {
    NSString *title = success ? @"Success" : @"Error";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end

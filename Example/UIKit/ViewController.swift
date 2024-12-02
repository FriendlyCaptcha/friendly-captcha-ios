import UIKit
import WebKit
import FriendlyCaptcha

class ViewController: UIViewController, UITextFieldDelegate {
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5

        // 1. The form submission button starts out disabled.
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let exampleCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This is an example app.\nYou can enter any username or password."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // A UIView is created to contain the FriendlyCaptcha Widget view.
    private let captchaContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let handle = FriendlyCaptcha(sitekey: "FCMGD7SIQS6JUH0G")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFriendlyCaptcha()
    }

    // 2. When either the username field or the password field are focused,
    // `handle.start()` is called, allowing the widget to start solving.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        handle.start()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [
            loginTitleLabel,
            usernameTextField,
            passwordTextField,
            captchaContainer,
            registerButton,
            exampleCaptionLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            exampleCaptionLabel.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 10),
            captchaContainer.heightAnchor.constraint(equalToConstant: 70),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func setupFriendlyCaptcha() {
        let captchaWidget = handle.Widget()
        addChildViewController(captchaWidget)
        captchaContainer.addSubview(captchaWidget.view)
        captchaWidget.view.translatesAutoresizingMaskIntoConstraints = false

        // After adding the FriendlyCaptcha Widget view to the container,
        // make sure to set its contraints to the bounds of the container.
        // Otherwise, it may not be visible.
        NSLayoutConstraint.activate([
            captchaWidget.view.leadingAnchor.constraint(equalTo: captchaContainer.leadingAnchor),
            captchaWidget.view.trailingAnchor.constraint(equalTo: captchaContainer.trailingAnchor),
            captchaWidget.view.topAnchor.constraint(equalTo: captchaContainer.topAnchor),
            captchaWidget.view.bottomAnchor.constraint(equalTo: captchaContainer.bottomAnchor)
        ])

        captchaWidget.didMove(toParentViewController: self)

        // 3. If the widget successfully completes, the button is enabled.
        handle.onComplete { [weak self] _ in
            self?.registerButton.isEnabled = true
            self?.registerButton.backgroundColor = .systemBlue
        }

        // 4. If the widget errors, the button is _still_ enabled. This
        // "fail open" approach prevents the scenario where all users are
        // blocked from submitting the form.
        handle.onError { [weak self] _ in
            self?.registerButton.isEnabled = false
            self?.registerButton.backgroundColor = .gray
        }

        // 5. If the widget expires, the button is disabled. The user will
        // need to restart the widget.
        handle.onExpire { [weak self] _ in
            self?.registerButton.isEnabled = false
            self?.registerButton.backgroundColor = .gray
        }
    }
}

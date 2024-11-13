import UIKit
import WebKit
import FriendlyCaptcha

class ViewController: UIViewController {
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
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let captchaContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let handle = FriendlyCaptcha(sitekey: "FCMKRFNE60ACKCDC")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFriendlyCaptcha()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(captchaContainer)
        view.addSubview(registerButton)

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            captchaContainer.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            captchaContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            captchaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            captchaContainer.heightAnchor.constraint(equalToConstant: 70),

            registerButton.topAnchor.constraint(equalTo: captchaContainer.bottomAnchor, constant: 20),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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

        NSLayoutConstraint.activate([
            captchaWidget.view.leadingAnchor.constraint(equalTo: captchaContainer.leadingAnchor),
            captchaWidget.view.trailingAnchor.constraint(equalTo: captchaContainer.trailingAnchor),
            captchaWidget.view.topAnchor.constraint(equalTo: captchaContainer.topAnchor),
            captchaWidget.view.bottomAnchor.constraint(equalTo: captchaContainer.bottomAnchor)
        ])

        captchaWidget.didMove(toParentViewController: self)

        handle.onComplete { [weak self] _ in
            self?.registerButton.isEnabled = true
            self?.registerButton.backgroundColor = .systemBlue
        }

        handle.onError { [weak self] _ in
            self?.registerButton.isEnabled = false
            self?.registerButton.backgroundColor = .gray
        }

        handle.onExpire { [weak self] _ in
            self?.registerButton.isEnabled = false
            self?.registerButton.backgroundColor = .gray
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        handle.start()
    }
}

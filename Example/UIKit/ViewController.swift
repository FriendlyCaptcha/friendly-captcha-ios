import UIKit
import WebKit
import FriendlyCaptcha

let alwaysSuccess = false

class ViewController: UIViewController, UITextFieldDelegate {
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
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

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
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
            loginButton,
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

            exampleCaptionLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            captchaContainer.heightAnchor.constraint(equalToConstant: 70),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
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
            self?.loginButton.isEnabled = true
            self?.loginButton.backgroundColor = .systemBlue
        }

        // 4. If the widget errors, the button is _still_ enabled. This
        // "fail open" approach prevents the scenario where all users are
        // blocked from submitting the form.
        handle.onError { [weak self] _ in
            self?.loginButton.isEnabled = false
            self?.loginButton.backgroundColor = .gray
        }

        // 5. If the widget expires, the button is disabled. The user will
        // need to restart the widget.
        handle.onExpire { [weak self] _ in
            self?.loginButton.isEnabled = false
            self?.loginButton.backgroundColor = .gray
        }
    }

    // 6. When the captcha is done and the response available, it needs to
    // be sent to the back-end for verification, along with any other
    // server-side validation.
    //
    // See https://developer.friendlycaptcha.com/docs/v2/getting-started/verify
    @objc private func loginButtonTapped() {
        if alwaysSuccess {
            showAlert(message: "Always successful!", success: true)
            return
        }

        let url = URL(string: "http://localhost:3600/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: String] = [
            "username": usernameTextField.text ?? "",
            "password": passwordTextField.text ?? "",
            "frc-captcha-response": handle.getResponse()
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            print("Error serializing login data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error logging in: \(error)")
                return
            }

            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])

                    if let responseDict = jsonResponse as? [String: Any],
                       let message = responseDict["message"] as? String,
                       let success = responseDict["success"] as? Bool {
                        self.showAlert(message: message, success: success)
                    }
                } catch {
                    print("Error parsing response: \(error)")
                }
            }
        }.resume()
    }

    private func showAlert(message: String, success: Bool) {
        let alert = UIAlertController(title: success ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

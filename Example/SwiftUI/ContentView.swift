import SwiftUI
import WebKit
import FriendlyCaptcha

let alwaysSuccess = false

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var disabled: Bool = true
    @FocusState private var isFocused: Bool
    @State private var showAlert = false
    @State private var alertSuccess = false
    @State private var alertMessage = ""

    private let handle = FriendlyCaptcha(
        sitekey: "FCMGD7SIQS6JUH0G"
    )

    var body: some View {
        VStack {
            HStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }

            // 1. When either the username field or the password field are focused,
            // `handle.start()` is called, allowing the widget to start solving.
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused)
                .onChange(of: isFocused) {
                    handle.start()
                }
                .padding(.bottom, 10)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused)
                .onChange(of: isFocused) {
                    handle.start()
                }
                .padding(.bottom, 10)

            FCWidgetView(handle: handle)
                .frame(height: 70)
                .padding(.bottom, 10)

            // 2. The form submission button starts out disabled.
            Button(action: {
                loginButtonTapped()
            }) {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(disabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .disabled(disabled)
            .padding(.bottom, 5)

            HStack{
                Text("This is an example app.\nYou can enter any username or password.")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }


        }
        .onAppear() {

            // 3. If the widget successfully completes, the button is enabled.
            handle.onComplete { _ in
                disabled = false
            }

            // 4. If the widget errors, the button is _still_ enabled. This
            // "fail open" approach prevents the scenario where all users are
            // blocked from submitting the form.
            handle.onError { _ in
                disabled = false
            }

            // 5. If the widget expires, the button is disabled. The user will
            // need to restart the widget.
            handle.onExpire { _ in
                disabled = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertSuccess ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .padding(.horizontal, 20)
    }

    // 6. When the captcha is done and the response available, it needs to
    // be sent to the back-end for verification, along with any other
    // server-side validation.
    //
    // See https://developer.friendlycaptcha.com/docs/v2/getting-started/verify
    func loginButtonTapped() {
        if alwaysSuccess {
            alertMessage = "Always successful!"
            alertSuccess = true
            showAlert = true
            return
        }

        let url = URL(string: "http://localhost:3600/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: String] = [
            "username": username,
            "password": password,
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
                        alertMessage = message
                        alertSuccess = success
                        showAlert = true
                    }
                } catch {
                    print("Error parsing response: \(error)")
                }
            }
        }.resume()
    }
}

// This struct wraps a FriendlyCaptcha instance to make it
// usable in SwiftUI. It's a minimal wrapper that just returns
// the instance's WebView ViewController.
struct FCWidgetView: UIViewControllerRepresentable {
    let handle: FriendlyCaptcha

    func makeUIViewController(context: Context) -> UIViewController {
        handle.Widget()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    ContentView()
}

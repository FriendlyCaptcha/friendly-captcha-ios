import SwiftUI
import WebKit
import FriendlyCaptcha

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var disabled: Bool = true
    @FocusState private var isFocused: Bool

    private let handle = FriendlyCaptcha(
        sitekey: "FCMGD7SIQS6JUH0G"
    )

    var body: some View {
        VStack {
            HStack {
                Text("Login")
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
            Button(action: {}) {
                Text("Register")
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


        }.onAppear() {

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
        .padding(.horizontal, 20)
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

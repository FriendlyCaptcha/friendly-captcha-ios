import SwiftUI
import WebKit
import FriendlyCaptcha

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var disabled: Bool = true
    @FocusState private var isFocused: Bool

    private let handle = FriendlyCaptcha(
        sitekey: "FCMKRFNE60ACKCDC"
    )

    var body: some View {
        VStack(spacing: 20) {

            // 1. When either the username field or the password field are focused,
            // `handle.start()` is called, allowing the widget to start solving.
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .focused($isFocused)
                .onChange(of: isFocused) {
                    handle.start()
                }

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .focused($isFocused)
                .onChange(of: isFocused) {
                    handle.start()
                }

            FCWidgetView(handle: handle)
                .frame(height: 70)
                .padding(.horizontal, 20)

            // 2. The submit button starts out disabled.
            Button(action: {}) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(disabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .disabled(disabled)
            .padding(.horizontal, 20)

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
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
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

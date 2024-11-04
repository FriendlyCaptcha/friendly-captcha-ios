import SwiftUI
import FriendlyCaptcha

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            FriendlyCaptchaWidget()
                .padding(.horizontal, 20)
                .frame(height: 70)
            
            Button(action: {
                print("Username: \(username), Password: \(password)")
            }) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct FriendlyCaptchaWidget: UIViewRepresentable {
    func makeUIView(context: Context) -> FriendlyCaptcha.Widget {
        return Widget()
    }
    
    func updateUIView(_ uiView: FriendlyCaptcha.Widget, context: Context) {}
}

#Preview {
    ContentView()
}

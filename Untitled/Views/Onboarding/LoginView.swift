import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    
    @EnvironmentObject var model: ContentModel
    @Binding var isFormSubmitted: Bool  // State variable to track form submission
    
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    
    var body: some View {
        
        VStack (spacing: 25) {
            
            Title(subTitle: "Log In")
            
            CustomTextField(title: "Email", data: $email)
            
            CustomTextField(title: "Password", data: $password)
            
            Button {
                // Your logic here to login
                signIn()
                // Then set the isFormSubmitted flag to true
                isFormSubmitted = true
            } label: {
                CustomButton(text: "Submit")
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            DispatchQueue.main.async {
                
                if error == nil {
                    
                    print("bitchassPussy")
                }
                else {
                    errorMessage = error!.localizedDescription
                }
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isFormSubmitted: .constant(false))  // Added both bindings
            .environmentObject(ContentModel())  // Added this line to satisfy the
    }
}

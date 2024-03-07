import SwiftUI
import Firebase
import FirebaseAuth

struct CreateAccountView: View {
    
    @EnvironmentObject var model: ContentModel
    @Binding var isFormSubmitted: Bool  // State variable to track form submission
    
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var password = ""
    @State var name: String = ""
    @State var errorMessage: String?
    
    var body: some View {
        
        NavigationView {
            VStack (spacing: 25) {
                
                Title(subTitle: "Create Account")
                
                CustomTextField(title: "First Name", data: $firstName)
                
                CustomTextField(title: "Last Name", data: $lastName)
                
                CustomTextField(title: "Email", data: $email)
                
                CustomTextField(title: "Password", data: $password)
                
                Button {
                    // Your logic here to create an account
                    createAccount()
                    // Then set the isFormSubmitted flag to true
                    isFormSubmitted = true
                } label: {
                    CustomButton(text: "Submit")
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
    }
    func createAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { [self] result, error in
            DispatchQueue.main.async {
                if error == nil {
                    // User account created successfully, now sign in the user
                    Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, signInError in
                        if signInError == nil {
                            // User signed in successfully
                           
                            createName()
                            userCreation()
                           
                        } else {
                            errorMessage = signInError!.localizedDescription
                        }
                    }
                } else {
                    errorMessage = error!.localizedDescription
                }
            }
        }
    }
    
    func createName() {
        name = firstName + " " + lastName
    }
    
    func userCreation() {
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let path = db.collection("Users").document(currentUser.uid)
            
            let userData: [String: Any] = [
                "id": currentUser.uid,
                "name": name,
                "rating": 3,
                "comments": [""],
                "guestEvents": [""],
                "hostEvents": [""],
                "numberOfCoins": 0,
                "isVerified": false,
                "hostRating": 5
            ]
            
            path.setData(userData) { error in
                if let error = error {
                    // Handle the error if data couldn't be added to Firestore
                    print("Error creating user document: \(error.localizedDescription)")
                } else {
                    // User document created successfully
                    print("User document created in Firestore.")
                }
            }
        } else {
            // Handle the case where there's no signed-in user
            print("No user is currently signed in.")
        }
    }
}

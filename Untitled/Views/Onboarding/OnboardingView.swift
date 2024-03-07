import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth

enum ActiveSheet: Identifiable {
    case createAccount, login
    
    var id: Int {
        hashValue
    }
}

struct OnboardingView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var tabSelection = 0
    
    @State private var activeSheet: ActiveSheet? = nil
    
    @State var isFormSubmitted = false
    
    var body: some View {
      
            NavigationView {
                
                VStack {
                    
                    TabView(selection: $tabSelection) {
                        
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [model.customColor1, model.customColor2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                 // This will make the gradient cover the whole screen area
                            
                            VStack {
                                Text("THE FUTURE OF EVENTS IS NOW.")
                                    .font(.custom("AvenirNext-Bold", size: 50))
                                    .italic()
                                    .onAppear {
                                        model.signOut() // Call signOut when this view appears
                                    }
                                
                                Text("Party anywhere, anytime, on your own rules.")
                                    .font(.title2)
                                    .bold()
                                    .padding(.top)
                                
                                Text("Make money hosting parties, open houses or any events you like.")
                                    .font(.title2)
                                    .bold()
                                    .padding()
                                
                                Text("No more waiting in line at the club, no more overpriced drinks.")
                                    .font(.title2)
                                    .bold()
                                    .padding()
                                
                                Text("Get your ticket on the app and go where you please, do what you want. As you should.")
                                    .font(.title2)
                                    .bold()
                                    .padding()
                                
                                
                            }
                      
                        }
                        .frame(height: 900)
                        .tag(0)
                        
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [model.customColor1, model.customColor2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                 // This will make the gradient cover the whole screen area
                        
                        VStack {
                            
                            
                            if isFormSubmitted == true {
                                
                                Spacer()
                                
                                NavigationLink {
                                    HomePageView()
                                        .navigationBarBackButtonHidden(true)
                                    
                                } label: {
                                    CustomButton(text: "Let's go")
                                        .onTapGesture {
                                            model.isLoggedIn = true
                                        }
                                }
                                .buttonStyle(.plain)
                                
                                
                               Spacer()
                                
                                
                            } else {
                                Button {
                                    activeSheet = .createAccount
                                } label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundColor(.black)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                        Text("Create Account")
                                            .foregroundColor(.white)
                                            .font(.custom("AvenirNext-Bold", size: 25))
                                            .italic()
                                            .padding()
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    signInWithGoogle()
                                } label: {
                                    ZStack {
                                        
                                        RoundedRectangle(cornerSize: CGSize(width: CGFloat(15), height: CGFloat(15)))
                                            .frame(height: 75)
                                            .foregroundColor(.black)
                                            .overlay(
                                                RoundedRectangle(cornerSize: CGSize(width: CGFloat(15), height: CGFloat(15)))
                                                    .stroke(Color.black, lineWidth: 1)
                                            )
                                        
                                            .padding(.horizontal)
                                        
                                        
                                        HStack {
                                            
                                            Image("googlelogo1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 55)
                                                .padding()
                                            
                                            
                                            Text("Sign in with Google")
                                                .foregroundColor(.white)
                                                .font(.custom("AvenirNext-Bold", size: 25))
                                                .italic()
                                            
                                            
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    activeSheet = .login
                                } label: {
                                    Text("Already have an account? Log in")
                                        .underline()
                                        .foregroundColor(.black)
                                        .padding()
                                }
                                .buttonStyle(.plain)
                                
                            }
                        }
                        }
                        .frame(height: 900)
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                .edgesIgnoringSafeArea(.all)
                
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .createAccount:
                        CreateAccountView(isFormSubmitted: $isFormSubmitted)
                    case .login:
                        LoginView(isFormSubmitted: $isFormSubmitted)
                    }
                }
            }
  
        
        
    }
    
    
    func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let user = result?.user, let idToken = user.idToken else { return }
                let accessToken = user.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                let db = Firestore.firestore()
                
                if let currentUser = Auth.auth().currentUser {
                    currentUser.link(with: credential) { _, error in
                        if let error = error {
                            print("Error linking Google account: \(error.localizedDescription)")
                            return
                        }
                        print("Google account linked successfully.")
                        self.isFormSubmitted = true
                    }
                } else {
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        let path = db.collection("Users").document(authResult!.user.uid)
                        
                        path.getDocument { (document, error) in
                            if let document = document, document.exists {
                                print("User already exists, no need to update Firestore")
                                self.isFormSubmitted = true
                            } else {
                               
                                                print("User document created in Firestore.")
                                self.isFormSubmitted = true
                               
                            }
                        }
                      
                    }
                }
            }
        }

    private func handleUserSignInOrCreate(authResult: AuthDataResult) {
        let db = Firestore.firestore()
        let path = db.collection("Users").document(authResult.user.uid)

        path.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User already exists, no need to update Firestore")
                self.isFormSubmitted = true
            } else {
                // Create new Firestore document for the user
                // Define userData based on authResult.user details
                let userData: [String: Any] = [:
                    // User data here
                ]
                
                path.setData(userData) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                    } else {
                        print("User document created in Firestore.")
                        self.isFormSubmitted = true
                    }
                }
            }
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(ContentModel())
    }
}

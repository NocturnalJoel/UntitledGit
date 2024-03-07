//
//  VerifyHostView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-10-06.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SafariServices
import FirebaseFunctions

struct VerifyHostView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var showWebView = false
    
    @State private var imageURLString: String?
    
    @State var fullName = ""
    
    @State var address = ""
    
    @State var typeOfID = ""
    
    @State private var showImagePicker = false
    
    @State private var image: UIImage?
    
    @State private var onboardingURL: String?
    
    var body: some View {
        
        VStack {
            Title(subTitle: "You need to get verified before posting an event")
            
            CustomTextField(title: "Full Name on ID", data: $fullName)
            
            CustomTextField(title: "Adress on ID", data: $address)
            
            CustomTextField(title: "Type of card/ID", data: $typeOfID)
            
            
            
            Button {
                showImagePicker = true
            } label: {
                CustomUploadPicture(text: "Picture of ID")
                    .accentColor(.black)
            }
            .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $image, onComplete: uploadImage)
                        }
            .buttonStyle(.plain)

            Button {
                submitForApproval()
                createStripeSellerAccount()
                showWebView = true
            } label: {
                CustomButton(text: "Advance")
            }
            .sheet(isPresented: $showWebView) {
                if let url = onboardingURL, let urlObject = URL(string: url) {
                    SafariView(url: urlObject)
                }
            }
            .buttonStyle(.plain)


            
            ZStack {
                Text("You need to enter this data to confirm your address and identity before hosting Events, then create a seller's account using Stripe to receive payments.")
                
                CustomFrame(height: 135)
                                }
            .padding()

            
        }
        .alert(isPresented: $model.showAlert) {
                    Alert(title: Text(model.alertTitle), message: Text(model.alertMessage), dismissButton: .default(Text("OK")))
                }
        .onOpenURL { url in
                    handleURL(url)
            print("open url called")
                }
    }
    
    func createStripeSellerAccount() {
        let functions = Functions.functions()
        functions.httpsCallable("createStripeAccount").call { result, error in
            if let error = error {
                // Handle the error
                print(error.localizedDescription)
            } else if let accountId = (result?.data as? [String: Any])?["accountId"] as? String {
                // Use the account ID to generate the onboarding link
                updateFirestoreWithStripeAccountId(accountId)
                generateOnboardingLink(accountId: accountId)
            }
        }
    }
    
    func updateFirestoreWithStripeAccountId(_ accountId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("Users").document(userId).updateData([
            "stripeAccountId": accountId
        ]) { error in
            if let error = error {
                print("Error updating Firestore with Stripe account ID: \(error)")
            } else {
                print("Firestore updated with Stripe account ID successfully")
            }
        }
    }
    
    func handleURL(_ url: URL) {
    
    print("handle url called")
    print("Received URL: \(url.absoluteString)")

    if url.scheme == "returnurl" {
        
        print("return url correct ")
        
        updateFirestoreForCurrentUser()
        
        print(" firestore update called")
        
        if let accountId = model.currentUser?.stripeAccountId {
            
            fetchAndUpdateStripeAccountInfo(accountId: accountId)
        }
        displayNotification(title: "Onboarding Complete", message: "Your seller account setup is complete.")
        print("returned correctly")
        
        
    } else if url.scheme == "refreshurl" {
        displayNotification(title: "Onboarding Incomplete", message: "The onboarding process was not completed. Please start over.")
        print("refreshed correctly")
    }else {
        print("neither url recognized")
    }
}
    
    func updateFirestoreForCurrentUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("Users").document(userId).updateData([
            "isVerified": true
        ]) { error in
            if let error = error {
                print("Error updating Firestore: \(error)")
            } else {
                print("Firestore updated successfully")
            }
        }
    }
    
    func fetchAndUpdateStripeAccountInfo(accountId: String) {
        
        print(accountId)
        
        let functions = Functions.functions()
        functions.httpsCallable("fetchStripeAccountInfo").call(["accountId": accountId]) { result, error in
            if let error = error {
                print("Error fetching Stripe info: \(error.localizedDescription)")
                print("cloud func called but error")
            } else if let resultData = result?.data as? [String: Any], let message = resultData["message"] as? String {
                print(message)
                print("cloud func called correctly")
                // Update UI or take other actions as necessary
            }
        }
    }

    func displayNotification(title: String, message: String) {
            model.alertTitle = title
            model.alertMessage = message
            model.showAlert = true
        }
    
    func generateOnboardingLink(accountId: String) {
        let functions = Functions.functions()
        functions.httpsCallable("generateOnboardingLink").call(["accountId": accountId]) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let url = (result?.data as? [String: Any])?["url"] as? String {
                self.onboardingURL = url
                showWebView = true
            }
        }
    }
    
    func openStripeOnboarding(url: String) {
        if let onboardingURL = URL(string: url) {
            showWebView = true // Triggers the display of the SafariView
            // Pass onboardingURL to SafariView
        }
    }
    
    func uploadImage(image: UIImage?) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let image = image else { return }
        let storageRef = Storage.storage().reference().child("userImages/\(currentUserID).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                // Handle error
                print(error?.localizedDescription ?? "Unknown error occurred")
                return
            }
            storageRef.downloadURL { [self] (url, error) in
                guard let downloadURL = url else {
                    // Handle error
                    print(error?.localizedDescription ?? "Unknown error occurred")
                    return
                }
                // Update the state variable
                DispatchQueue.main.async {
                    self.imageURLString = downloadURL.absoluteString
                }
            }
        }
    }

    func submitForApproval() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User ID or Image URL not found")
            return
        }
        
        let db = Firestore.firestore()
        let verificationData: [String: Any] = [
            "fullName": fullName,
            "address": address,
            "typeOfID": typeOfID
        ]
        
        db.collection("Verifications").document(currentUserID).setData(verificationData) { error in
            if let error = error {
                print("Error submitting for approval: \(error)")
            } else {
                print("Successfully submitted for approval")
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Environment(\.presentationMode) var presentationMode
        var onComplete: (UIImage?) -> Void
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self, onComplete: onComplete)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            var parent: ImagePicker
            var onComplete: (UIImage?) -> Void
            
            init(_ parent: ImagePicker, onComplete: @escaping (UIImage?) -> Void) {
                self.parent = parent
                self.onComplete = onComplete
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.image = image
                    onComplete(image)
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }


}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

#Preview {
        VerifyHostView()
        .environmentObject(ContentModel())
    }


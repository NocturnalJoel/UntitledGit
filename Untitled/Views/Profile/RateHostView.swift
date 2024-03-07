//
//  RateHostView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-11-16.
//

import SwiftUI
import FirebaseFirestore


struct RateHostView: View {
    
    @State var comment:String = ""
    
    @EnvironmentObject var model: ContentModel
    
    @State var numberOfStars:Int = 5
    
    var user:User
    
    var body: some View {
        
        VStack{
            Title(subTitle: "Rate Host")
            
            ZStack {
                
                TextFrame(title: "Stars / 5", text: "")
                
                ZStack {
                    Picker("Stars / 5", selection: $numberOfStars) {
                                    ForEach(1..<6, id: \.self) { number in
                                        Text("\(number) stars")
                                            .foregroundColor(.white)
                                            .font(.custom("AvenirNext", size: 15))
                                        
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 150, height:50)
                            
                }
                .frame(width: 140, height: 30)
                .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [model.customColor1, model.customColor2]), // Define your gradient colors
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .cornerRadius(5) // Optional: Add corner radius for rounded edges
                            )
                .padding(.leading, 135)
                
                    
                                
                
            }
            
            CustomTextField(title: "Comment", data: $comment)
            
            
            Button {
                updateHostRatingAndComment(user: user, rating: numberOfStars, comment: comment)
            } label: {
                CustomButton(text: "CONFIRM")
            }
            .buttonStyle(.plain)

            
            
        }
        
    }
    func updateHostRatingAndComment(user: User, rating: Int, comment: String) {
            let db = Firestore.firestore()
            guard let userId = user.id else {
                print("User ID is nil")
                return
            }

            let userRef = db.collection("Users").document(userId)

            // Atomically add a new rating to the hostStars array and a new comment to the hostComments array
            userRef.updateData([
                "hostStars": FieldValue.arrayUnion([rating]),
                "hostComments": FieldValue.arrayUnion([comment])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
}


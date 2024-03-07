//
//  ProfileView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var model: ContentModel
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                VStack {
                    Title(subTitle: "🤴 Profile 👸")
                    
                    Text(model.currentUser?.name ?? "")
                    Text(model.currentUser?.id ?? "")
                    
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                            .frame(width: 100, height: 100)
                        Image(systemName: "person.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 50, height: 50)
                    }
                    
                    if let user = model.currentUser {
                                TextFrame(title: "Rating as Host", text: "\(user.averageHostStars)/5 stars")
                                
                                ForEach(user.hostComments, id: \.self) { comment in
                                    Text(comment)
                                }

                                TextFrame(title: "Rating as Guest", text: "\(user.averageGuestStars)/5 stars")

                                ForEach(user.guestComments, id: \.self) { comment in
                                    Text(comment)
                                }
                            }
                    
                    NavigationLink(destination: MyEventsView()) {
                        CustomButton(text: "My Events")
                    }
                    Button {
                        model.signOut()
                    } label: {
                        CustomButton(text: "Log Out")
                    }
                    .buttonStyle(.plain)

                    
                   

                    
                    
                    Spacer()
                }
            }
        }
        .accentColor(.white)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ContentModel())
    }
}

//
//  HomePageView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var model: ContentModel
    var body: some View {
        
        
        TabView {
            
            
            
          FeaturedView()
                .tabItem {
                    VStack{
                        Image(systemName:"star")
                            .foregroundColor(.black)
                        Text("Featured")
                            .foregroundColor(.black)
                    }
                }
          
            EventsView()
                .tabItem {
                VStack{
                    Image(systemName:"calendar")
                        .foregroundColor(.black)
                    Text("All Events")
                        .foregroundColor(.black)
                }
            }
            
            ProfileView()
                .tabItem {
                VStack{
                    Image(systemName:"person")
                        .foregroundColor(.black)
                    Text("Profile")
                        .foregroundColor(.black)
                }
            }
            
            
            
        }
        .accentColor(.purple)
        .onAppear{
            model.fetchCurrentUser()
            model.fetchEvents()
            model.fetchUsers()
        }
        
        
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(ContentModel())
    }
}

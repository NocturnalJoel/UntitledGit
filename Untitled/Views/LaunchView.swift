//
//  LaunchView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2024-01-11.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    
    var body: some View {
        
        if model.isLoggedIn{
            HomePageView()
                .onAppear{
                    checkLogin()
                }
            
        } else if model.isLoggedIn == false {
            OnboardingView()
                .onAppear{
                    checkLogin()
                }
            
        }
        
    }
    
    func checkLogin() {
        
        model.isLoggedIn = Auth.auth().currentUser != nil
        
    }

}

#Preview {
    LaunchView()
}

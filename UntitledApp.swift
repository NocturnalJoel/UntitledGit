//
//  UntitledApp.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI
import Firebase
import GoogleSignIn
import UIKit
import Stripe
import FirebaseFunctions



@main
struct UntitledApp: App {
    
    @EnvironmentObject var model: ContentModel
    
    
    init() {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "pk_test_51JiMu1EdeKajQJDE9v0I9kYzg8rYPfLr1siZliCqqllYl79I8bXTmua0hrnG1pBEdsn9wQjtgjex32GIBm6K1aOm00bBE1fwwk"
        
      
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(ContentModel())
        }
        
    }
    
    


}





//
//  GuestElement.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-20.
//

import SwiftUI

struct GuestElement: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(radius: 15)
            
            VStack {
                Text("Nathaniel DuCharme")
                    .font(.custom("AvenirNext-Bold", size: 22))
                
                HStack {
                    Text("Number of Coins 🥇: ")
                        .font(.custom("AvenirNext", size: 22))
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                            .frame(width: 60,height: 60)
                        
                        Text("5")
                            .font(.custom("AvenirNext-Bold", size: 22))
                    }
                    
                    
                    
                }
                .padding(.top)
                
            }
            
        }
        .padding(.top)
        .frame(height: 200)
        .padding(.horizontal)
        
    }
}

struct GuestElement_Previews: PreviewProvider {
    static var previews: some View {
        GuestElement()
            .environmentObject(ContentModel())
    }
}

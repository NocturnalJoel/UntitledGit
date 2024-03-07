//
//  Button.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct CustomButton: View {
    
    @EnvironmentObject var model:ContentModel
    
    var text: String
    
    var height:CGFloat = 80
    
    var fontSize:CGFloat = 40
    

    
    var body: some View {
        
        
        
        
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: height)
                .padding(.horizontal)
            Text(text)
                .foregroundColor(.white)
                .font(.custom("AvenirNext-Bold", size: fontSize))
                .italic()
                .padding(.horizontal)
        }
        
        
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(text: "Click On Me")
    }
}

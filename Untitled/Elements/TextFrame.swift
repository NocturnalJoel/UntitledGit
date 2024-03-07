//
//  TextFrame.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct TextFrame: View {
    
    @EnvironmentObject var model: ContentModel
    
    var title:String
    
    var text:String
    
    var height:CGFloat = 48
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2 // Adjust the line width as needed
                )
                .frame(height: height)
            
            HStack {
                Text("\(title) :")
                    .font(.custom("AvenirNext-Bold", size: 20))
                
                Text(text)
                    .font(.custom("AvenirNext", size: 20))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct TextFrame_Previews: PreviewProvider {
    static var previews: some View {
        TextFrame(title: "Title", text: "Text")
    }
}

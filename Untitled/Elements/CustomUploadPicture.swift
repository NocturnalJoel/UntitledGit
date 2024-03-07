//
//  CustomUploadPicture.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-18.
//

import SwiftUI

struct CustomUploadPicture: View {
    
    @EnvironmentObject var model: ContentModel
    
    var text = "Picture"
    
    var body: some View {
        
        ZStack {
            TextFrame(title: text, text: "")
            HStack {
                Spacer()
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 32)
                    
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 60)
                
            }
        }
    }
}

struct CustomUploadPicture_Previews: PreviewProvider {
    static var previews: some View {
        CustomUploadPicture()
            .environmentObject(ContentModel())
    }
}

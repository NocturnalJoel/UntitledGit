//
//  CustomFrame.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-16.
//

import SwiftUI

struct CustomFrame: View {
    
    @EnvironmentObject var model:ContentModel
    var height:Double = 48
    
    
    var body: some View {
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
    }
}

struct CustomFrame_Previews: PreviewProvider {
    static var previews: some View {
        CustomFrame()
            .environmentObject(ContentModel())
    }
}

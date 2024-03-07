//
//  CustomTextField.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct CustomTextField: View {
    
    @EnvironmentObject var model:ContentModel
    
    
    var title:String
    
    @Binding var data:String
    
    var height:CGFloat = 48
    
    
    var body: some View {
        
        ZStack {
            CustomFrame()
            
            HStack {
                Text("\(title):")
                    .font(.custom("AvenirNext-Bold", size: 18))
                    .lineLimit(1)
                    .padding(.leading)
                
                TextField(title, text: $data)
                    .font(.custom("AvenirNext", size: 20))
                
                
            }
            
            
        }
        .padding(.horizontal)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(title: "Name", data: Binding.constant("penis"))
    }
}

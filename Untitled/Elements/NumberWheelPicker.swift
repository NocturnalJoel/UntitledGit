//
//  NumberWheelPicker.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-11-13.
//

import SwiftUI

struct NumberWheelPicker: View {
    
    @EnvironmentObject var model:ContentModel
    
    @Binding var selectedNumber: Double
    
    var body: some View {
        ZStack {
            
            TextFrame(title: "", text: "")
            
            ZStack {
                Picker("Select Cost", selection: $selectedNumber) {
                                ForEach(1..<101, id: \.self) { number in
                                    Text("\(number) $")
                                        .foregroundColor(.white)
                                        .font(.custom("AvenirNext", size: 15))
                                    
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 150, height:50)
                        
            }
            .frame(width: 140, height: 30)
            .background(
                            LinearGradient(
                                gradient: Gradient(colors: [model.customColor1, model.customColor2]), // Define your gradient colors
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(5) // Optional: Add corner radius for rounded edges
                        )
            .padding(.leading, 135)
            
                
                            
            
        }
    }
}

//
//  CustomWheelPicker.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-16.
//

import SwiftUI

struct CustomWheelPicker: View {
    
    @EnvironmentObject var model:ContentModel
    
    @Binding var selectedDistance: Double
    
    var body: some View {
        ZStack {
            
            TextFrame(title: "Max Distance", text: "")
            
            ZStack {
                Picker("Select Distance", selection: $selectedDistance) {
                                ForEach(1..<101, id: \.self) { distance in
                                    Text("\(distance) km")
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



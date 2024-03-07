//
//  CustomDatePicker.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-16.
//

import SwiftUI

struct CustomDatePicker: View {
    
    @EnvironmentObject var model: ContentModel
    
    @Binding var selectedDate: Date
    
    @State var isDatePickerVisible = false
    
    @State var selectedDistance:Double = 1

    var body: some View {
        ZStack {
            CustomFrame()
            
            HStack {
                Text("Select a Date:")
                    .font(.custom("AvenirNext-Bold", size: 18))
                
                Button(action: {
                    isDatePickerVisible.toggle()
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 32)
                            .padding(.horizontal)
                        Text("\(formattedSelectedDate)")
                            .foregroundColor(.white)
                            .font(.custom("AvenirNext", size: 15))
                            .italic()
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        
        ZStack {
            
            if isDatePickerVisible {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .background(Color.white)
                
            }
           
        }
    }
    var formattedSelectedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM, yyyy" // Customize the date format here
            return formatter.string(from: selectedDate)
        }
    
    
}



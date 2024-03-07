//
//  CustomTimePicker.swift
//  Untitled
import SwiftUI

struct CustomTimePicker: View {
    
    @EnvironmentObject var model: ContentModel
    
    @Binding var selectedTime: Date  // This will be the time selected by the user
    
    @State var isTimePickerVisible = false
    
    var body: some View {
        ZStack {
            CustomFrame()
            
          
                HStack {
                    Text("Select Time:")
                        .font(.custom("AvenirNext-Bold", size: 18))
                    
                    Button(action: {
                        isTimePickerVisible.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 160, height: 32)
                                .padding(.horizontal)
                                .offset(x: 15)
                            Text(formattedSelectedTime)
                                .foregroundColor(.white)
                                .font(.custom("AvenirNext", size: 15))
                                .italic()
                                .padding(.horizontal)
                                .offset(x: 15)
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
        }
        .padding(.horizontal)
        .padding(.top, 15)
        
        if isTimePickerVisible {
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)
                .background(Color.white)
        }
    }
    
    var formattedSelectedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // Customize the time format here
        return formatter.string(from: selectedTime)
    }
}

#Preview {
        CustomTimePicker(selectedTime: .constant(Date()))
            .environmentObject(ContentModel())
    }


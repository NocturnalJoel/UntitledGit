//
//  CustomTabSelectionBar.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-18.
//

import SwiftUI

struct CustomTabSelectionBar: View {
    
    @EnvironmentObject var model: ContentModel
    
    @Binding var selection: Int
    
    var body: some View {
       
        HStack {
            Spacer()
            
            
            Button {
                selection = 0
            } label: {
                
                ZStack {
                    CustomFrame(height: 45)
                    
                    Image(systemName: "ticket")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(selection == 0 ? model.customColor1 : Color.gray)
                        .padding(10)
                }
            }
            
            
            
            Spacer()
            
            
            Button {
                selection = 1
            } label: {
                ZStack {
                    CustomFrame(height: 45)
                    
                    Image(systemName: "house")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(selection == 1 ? model.customColor1 : Color.gray)
                        .padding(10)
                }
                
                
            }
            
            
            
            Spacer()
        }
        .frame(height: 35)
        }
        
    }


struct CustomTabSelectionBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabSelectionBar(selection: Binding.constant(0))
            .environmentObject(ContentModel())
    }
}

//
//  MyEventsView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-18.
//

import SwiftUI

struct MyEventsView: View {
    @EnvironmentObject var model:ContentModel
    
   @State private var selection = 0
    
    var body: some View {
        
        
            
        VStack {
            
            
            switch selection {
            case 0:
                Title(subTitle: "🎟️ Guest 🎟️")
                CustomTabSelectionBar(selection: $selection)
                GuestView()
            case 1:
                Title(subTitle: "🏠 Host 🎉")
                CustomTabSelectionBar(selection: $selection)
                HostView()
                
            default :
                Title(subTitle: "🎟️ Guest 🎟️")
                CustomTabSelectionBar(selection: $selection)
                GuestView()
            }
            
            
            Spacer()
        }
    }
    
    
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
            .environmentObject(ContentModel())
    }
}

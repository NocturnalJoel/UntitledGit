//
//  FeaturedView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct FeaturedView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var showSheetFeatured = false
    
    @State var selectedEvent: Event?
    
    var body: some View {
        
        
        VStack {
            
            Title(subTitle: "✨ Featured ✨")
            
            ScrollView {
                
                      VStack {
                          
                          ForEach(model.allEvents, id: \.id) { event in
                              
                              if event.isFeatured {
                                  
                                  HelloDanaView(event: event, showSheet: $showSheetFeatured, buttonText: "Reservation")
                                      .onTapGesture {
                                          self.selectedEvent = event
                                          self.showSheetFeatured = true
                                      }

                                      
                                  
                              } else {
                                  
                              }
                          }
                      }
                     
                  }
            .sheet(isPresented: $showSheetFeatured) {
                            if let selectedEvent = selectedEvent {
                                ReservationView(event: selectedEvent)
                            }
                        }
            
            Spacer()
            
        }
     
        
            
    }
}

struct FeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedView()
    }
}

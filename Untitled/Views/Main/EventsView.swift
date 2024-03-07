//
//  EventsView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject var model: ContentModel
    
@State var sheetIsPresentedFilters = false
    
    @State var showSheetEvents = false
    
        @State var selectedEvent: Event?
    
    var body: some View {
        
        VStack {
            
            Title(subTitle: "🎉 All Events 🍾")
  /*
            Button {
                sheetIsPresentedFilters = true
            } label: {
                CustomButton(text: "Filters", height: 50, fontSize: 27)
            }

     */
            
            
            ScrollView {
                VStack (spacing: 40) {
                    ForEach(model.allEvents, id: \.id) { event in
                                        HelloDanaView(event: event, showSheet: $showSheetEvents, buttonText: "Reservation")
                           
                                            
                                            

                                    }
                      }
                      
                  }
                        
            
            Spacer()
        }
      /*  .sheet(isPresented: $sheetIsPresentedFilters) {
            FiltersView(sheetIsPresentedFilters: $sheetIsPresentedFilters)
                .environmentObject(model)
        }
       */
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(ContentModel())
    }
}

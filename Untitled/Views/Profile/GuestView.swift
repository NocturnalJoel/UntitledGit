//
//  GuestView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-18.
//

import SwiftUI

struct GuestView: View {
    
    @EnvironmentObject var model:ContentModel
    
    @State var isRateShowing = false
    
    @State var showSheet = false
    
    @State var selectedUser: User? = nil
    
    @State var selectedEvent: Event?
    
    var body: some View {
        
        
        ScrollView {
                  VStack {
                      ForEach(model.allEvents.filter { $0.guestNames.contains(model.currentUser?.name ?? "") }, id: \.id) { event in
                          // This is the view you want to repeat 5 times
                          
                          
                          Button {
                              selectedUser = model.usersArray.first(where: { $0.name == event.hostName })
                              isRateShowing = true
                              selectedEvent = event
                          } label: {
                              
                              HelloDanaView(event: event, showSheet: $showSheet, buttonText: "🥇 Buy Coins! 🥇")
                          }
                          .sheet(isPresented: $isRateShowing) {
                              if let user = selectedUser {
                                                          RateHostView(user: user)
                                                      }
                              }
                          .buttonStyle(.plain)
                      }
                  }
              }
        .padding(.top)
        .sheet(isPresented: $showSheet) {
            BuyCoinsView(event: selectedEvent!)
        }
        
    }
}

struct GuestView_Previews: PreviewProvider {
    static var previews: some View {
        GuestView()
            .environmentObject(ContentModel())
    }
}

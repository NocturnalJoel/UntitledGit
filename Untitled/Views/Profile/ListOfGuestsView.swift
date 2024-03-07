//
//  ListOfGuestsView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-20.
//

import SwiftUI

struct ListOfGuestsView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var isRateShowing = false
    
    @State var priceOfCoins:Double = 1
    
    var selectedEvent: Event
    
    var body: some View {
        
        VStack {
            
            Text("List of Guests")
            
                .font(.custom("AvenirNext-Bold", size: 30))
                .padding(.top)
            
            ZStack{
                
                CustomFrame(height: 100)
                
                HStack{
                    Text("Set the price for coins: ")
                        .font(.custom("AvenirNext-Bold", size: 17))
                    
                    ZStack {
                        
                        
                        NumberWheelPicker(selectedNumber: $priceOfCoins)
                    }
                }
                
                Button {
                    model.updateEventCoinPrice(event: selectedEvent, priceOfCoins: priceOfCoins)
                } label: {
                    
                    Text("Save")
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal)
            
            ScrollView {
                            VStack {
                                // Filter usersArray to include only those in the guestNames of selectedEvent
                                ForEach(model.usersArray.filter { selectedEvent.guestNames.contains($0.name ?? "") }, id: \.id) { user in
                                    Button {
                                        isRateShowing = true
                                    } label: {
                                        GuestElement() // Make sure GuestElement can display user data
                                    }
                                    .sheet(isPresented: $isRateShowing) {
                                        // Pass the user to RateView
                                        RateView(user: user)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
        }
    }
}



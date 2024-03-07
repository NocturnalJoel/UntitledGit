//
//  Card.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct Card: View {
    
    @Binding var showReservationSheet: Bool
    
    
        
        var buttonText: String
    
    init(showReservationSheet: Binding<Bool>? = nil, buttonText: String = "Reservation") {
           if let showReservationSheet = showReservationSheet {
               self._showReservationSheet = showReservationSheet
           } else {
               self._showReservationSheet = Binding.constant(false)
           }
           self.buttonText = buttonText
       }
    
    var body: some View {
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 15)
                .frame(height: 600)
                .foregroundColor(.black)
                
            
            VStack{
                Text("Projet X")
                    .font(.custom("AvenirNext-Bold", size: 40))
                    .foregroundColor(.white)
                
                Image("backyardPartyPic")
                    .resizable()
                    .frame(height: 160)
                    .padding(.horizontal)
                
                Divider()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.white)
                        .frame(height: 180)
                    
                    
                    VStack {
                        HStack{
                            Text("Time:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("Friday, October 13th, 2023")
                                .font(.custom("AvenirNext", size: 18))
                            Spacer()
                        }
                        
                        HStack{
                            Text("Distance:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("63 km")
                                .font(.custom("AvenirNext", size: 18))
                            Spacer()
                        }
                        HStack{
                            Text("Host:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("Johnny Boy")
                                .font(.custom("AvenirNext", size: 18))
                            Spacer()
                        }
                        HStack{
                            Text("Rating:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star")

                            Spacer()
                        }
                        HStack{
                            Text("Type:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("Open House")
                                .font(.custom("AvenirNext", size: 18))
                            Spacer()
                        }
                        HStack{
                            Text("Cost:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("Free")

                            Spacer()
                        }
                        HStack{
                            Text("Attendance:")
                                .font(.custom("AvenirNext-Bold", size: 18))
                                .padding(.leading)
                            Text("87/110")

                            Spacer()
                        }
                        
                    }
                }
                .padding(.horizontal)
               
                
                Button {
                    showReservationSheet = true
                } label: {
                    CustomButton(text: buttonText)
                }

            }
        }
        .padding(.horizontal)
        
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(showReservationSheet: Binding.constant(true))
            .environmentObject(ContentModel())
    }
}

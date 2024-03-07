//
//  ReservationView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-18.



import SwiftUI
import PassKit
import Firebase
import FirebaseFirestore
import Stripe
import FirebaseFunctions
import SafariServices



struct ReservationView: View {
    
    @EnvironmentObject var model:ContentModel
    var event: Event
    
    @State private var paymentStatus: String?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSafari = false
    @State private var stripeCheckoutURL: URL?
    
    var body: some View {
        VStack{
            
            Title(subTitle: "🎟️ Reservation: 1 ticket 🎟️")
            
            
                
                Text("You are about to make a reservation for 1 person for the price of:")
                    .font(.custom("AvenirNext", size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                ZStack{
                    CustomFrame(height: 55)
                        .frame(width: 70)
                    
                    Text("\(event.costOfEntry) $")
                        .font(.custom("AvenirNext-Bold", size: 20))
                }
                .padding(.top, 40)
            
            
            Text("The host might refuse your request. If so, you will be reimbursed.")
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal)
            
            Button {
                
                buyTicket()
            } label: {
                CustomButton(text: "CONFIRM")
                    .padding(.top, 40)
            }
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            .buttonStyle(.plain)
            
            
            
            Spacer()
        }
        .onOpenURL { url in
                        switch url.scheme {
                        case "SuccessURL":
                            // Handle the success case
                            self.alertMessage = "Payment Successful!"
                            self.showAlert = true

                        case "CancelURL":
                            // Handle the cancellation case
                            self.alertMessage = "Payment Canceled."
                            self.showAlert = true

                        default:
                            break
                        }
                    }
    }
    
    private func buyTicket() {
        isLoading = true

        // Prepare eventData and userData
        guard let userId = model.currentUser?.id,
              let userName = model.currentUser?.name else {
            alertMessage = "User information not available."
            showAlert = true
            isLoading = false
            return
        }

        let eventData: [String: Any] = [
            "eventId": event.eventId,
            "nameOfEvent": event.nameOfEvent,
            "ticketProductId": event.ticketProductId,
            "stripeAccountId": event.stripeAccountId,
            "costOfEntry": event.costOfEntry  // Assuming costOfEntry is an integer representing the price in CAD
        ]
        
        //print("ticketProductId: \(event.ticketProductId)")
        print("nameOfEvent: \(event.nameOfEvent)")

        let userData: [String: Any] = [
            "id": userId,
            "name": userName
        ]

        // Call the Firebase Function with the correctly structured data
        Functions.functions().httpsCallable("createCheckoutSession").call(["event": eventData, "user": userData]) { result, error in
            isLoading = false

            if let error = error {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let url = (result?.data as? [String: Any])?["url"] as? String else {
                alertMessage = "Failed to retrieve URL."
                showAlert = true
                return
            }

            // Redirect to Stripe Checkout Page
            model.redirectToStripe(url: url)
        }
    }


}





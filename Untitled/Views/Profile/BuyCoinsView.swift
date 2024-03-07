//
//  BuyCoinsView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-11-16.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFunctions

struct BuyCoinsView: View {
    var event: Event
    @EnvironmentObject var model: ContentModel
    @State private var selectedNumber = 1
    
    @State private var paymentStatus: String?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSafari = false
    @State private var stripeCheckoutURL: URL?
    
    var coinTotal:Int {
        selectedNumber * event.coinPrice
    }

    var body: some View {
        VStack {
            Text("Price per coin: \(event.coinPrice, specifier: "%.2f") $")
                .font(.title)

            Picker("Number of Coins", selection: $selectedNumber) {
                ForEach(1...40, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Text("Total: \(coinTotal)$")

            Button("Buy") {
                buyCoins()
            }
            .buttonStyle(.plain)
        }
    }

    private func buyCoins() {
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
            "coinProductId": event.coinProductId,
            "stripeAccountId": event.stripeAccountId,
            "coinTotal": coinTotal,
            "numberOfCoins": selectedNumber// Assuming costOfEntry is an integer representing the price in CAD
        ]
        
        //print("ticketProductId: \(event.ticketProductId)")
        print("nameOfEvent: \(event.nameOfEvent)")

        let userData: [String: Any] = [
            "id": userId,
            "name": userName
        ]

        // Call the Firebase Function with the correctly structured data
        Functions.functions().httpsCallable("createCheckoutSessionCoin").call(["event": eventData, "user": userData]) { result, error in
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

    func handlePaymentStatusCoin(_ status: String) {
            if status == "success" {
                // Update the UI for a successful payment
                alertMessage = "Payment Successful!"
                showAlert = true
            } else {
                // Update the UI for a canceled or failed payment
                alertMessage = "Payment Failed or Canceled."
                showAlert = true
            }
        }
}

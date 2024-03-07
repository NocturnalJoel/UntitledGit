//
//  ContentModel.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import CoreLocation
import GoogleSignIn

class ContentModel: ObservableObject {
    
    @Published var currentUser: User?
    
    @Published var allEvents: [Event] = []
    
    @Published var isLoggedIn = false
    
    @Published var selectedEvent: Event?
    
    @Published var filteredEventsProperty: [Event] = []
    
    @Published var usersArray: [User] = []
    
    @Published var showAlert = false
       @Published var alertTitle = ""
       @Published var alertMessage = ""
    
    @Published var selectedDate: Date = Date()
        @Published var selectedDistance: Double = 1
        @Published var selectedCost: Int = 0
        @Published var selectedRating: Int = 1
    
    
    
    @Published var customColor1 = Color(
        red: Double(132) / 255.0,
        green: Double(4) / 255.0,
        blue: Double(254) / 255.0,
        opacity: Double(255) / 255.0
    )
    
   @Published var customColor2 = Color(
        red: Double(163) / 255.0,
        green: Double(83) / 255.0,
        blue: Double(255) / 255.0,
        opacity: Double(255) / 255.0
    )
    
    init() {
 
    }
    
    func filteredEventsFunc(userLocation: CLLocationCoordinate2D?) {
        filteredEventsProperty = allEvents.filter { event in
            let eventLocation = CLLocationCoordinate2D(latitude: event.eventCoordinates.latitude, longitude: event.eventCoordinates.longitude)
            let eventDate = event.dateOfEvent.dateValue() // Converting Timestamp to Date

            let isDateMatching = selectedDate == nil || Calendar.current.isDate(eventDate, inSameDayAs: selectedDate)
            
            // Use a sentinel value for selectedDistance to indicate 'no limit'
            let defaultMaxDistance = 1000000.0 // A very large number
            let maxDist = (selectedDistance == 0) ? defaultMaxDistance : selectedDistance

            let isDistanceWithinRange: Bool
            if let userLoc = userLocation {
                isDistanceWithinRange = isWithinDistance(eventLocation: eventLocation, userLocation: userLoc, maxDistance: maxDist)
            } else {
                // If userLocation is nil, don't filter based on distance
                isDistanceWithinRange = true
            }

            let isCostMatching = (selectedCost == 0) || event.costOfEntry <= selectedCost
            let isRatingMatching = (selectedRating == 0) || event.hostRating >= selectedRating
            
            return isDateMatching && isDistanceWithinRange && isCostMatching && isRatingMatching
        }
    }





         func isWithinDistance(eventLocation: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D, maxDistance: Double) -> Bool {
            let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let eventLoc = CLLocation(latitude: eventLocation.latitude, longitude: eventLocation.longitude)
            let distance = userLoc.distance(from: eventLoc) / 1000 // Convert to kilometers
            return distance <= maxDistance
        }
    
    
    func fetchCurrentUser() {
        if let userId = Auth.auth().currentUser?.uid {
            self.isLoggedIn = true
            let db = Firestore.firestore()
            db.collection("Users").document(userId).getDocument { [weak self] document, error in
                if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    let hostStars = data["hostStars"] as? [Int] ?? []
                    let guestStars = data["guestStars"] as? [Int] ?? []
                    let averageHostStars = hostStars.isEmpty ? 0 : Double(hostStars.reduce(0, +)) / Double(hostStars.count)
                    let averageGuestStars = guestStars.isEmpty ? 0 : Double(guestStars.reduce(0, +)) / Double(guestStars.count)
                    
                    let currentUserProfile = User(
                        id: userId,
                        name: data["name"] as? String,
                        rating: data["rating"] as? Int,
                        comments: data["comments"] as? [String],
                        numberOfCoins: data["numberOfCoins"] as? Int,
                        isVerified: data["isVerified"] as? Bool ?? false,
                        hostStars: hostStars,
                        guestStars: guestStars,
                        hostComments: data["hostComments"] as? [String] ?? [],
                        guestComments: data["guestComments"] as? [String] ?? [],
                        averageHostStars: averageHostStars,
                        averageGuestStars: averageGuestStars,
                        stripeAccountId: data["stripeAccountId"] as? String ?? ""


                    )
                    DispatchQueue.main.async {
                        self?.currentUser = currentUserProfile
                       
                    }
                } else {
                    print("Document does not exist or there was an error fetching.")
                }
            }
        }
    }

    
    func fetchEvents() {
        let db = Firestore.firestore()

        db.collection("Events").getDocuments { (querySnapshot, err) in
            if let err = err {
                // Handle any errors appropriately
                print("Error getting documents: \(err)")
            } else {
                var eventsArray = [Event]()
                for document in querySnapshot!.documents {
                    let data = document.data()

                    let eventCoordinates = (data["eventCoordinates"] as? GeoPoint) ?? GeoPoint(latitude: 0, longitude: 0)
                    let createdDate = (data["createdDate"] as? Timestamp) ?? Timestamp()
                    let dateOfEvent = (data["dateOfEvent"] as? Timestamp) ?? Timestamp()
                    
                    // Initialize the Event struct with the document data
                    let event = Event(
                        id: document.documentID,
                        eventId: data["eventId"] as? String ?? "",
                        nameOfEvent: data["nameOfEvent"] as? String ?? "",
                        eventDescription: data["eventDescription"] as? String ?? "",
                        hostName: data["hostName"] as? String ?? "",
                        createdBy: data["createdBy"] as? String ?? "",
                        stripeAccountId: data["stripeAccountId"] as? String ?? "",
                        createdDate: createdDate,
                        eventLocation: data["eventLocation"] as? String ?? "",
                        eventCoordinates: eventCoordinates,
                        dateOfEvent: dateOfEvent,
                        imageUrl: data["imageUrl"] as? String ?? "",
                        maxAttendance: data["maxAttendance"] as? Int ?? 0,
                        costOfEntry: data["costOfEntry"] as? Int ?? 0,
                        ticketPriceId: data["ticketPriceId"] as? String ?? "",
                        ticketProductId: data["ticketProductId"] as? String ?? "",
                        coinPrice: data["coinPrice"] as? Int ?? 0,
                        coinPriceId: data["coinPriceId"] as? Int ?? 0,
                        coinProductId: data["coinProductId"] as? String ?? "",
                        isFeatured: data["isFeatured"] as? Bool ?? false,
                        hostRating: data["hostRating"] as? Int ?? 5,
                        guestNames: data["guestNames"] as? [String] ?? [""]
                    )
                    
                    eventsArray.append(event)
                }
                // Update the published array with the fetched events
                DispatchQueue.main.async {
                    self.allEvents = eventsArray
                }
            }
        }
    }

    


    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("Users").getDocuments { [weak self] (querySnapshot, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error getting documents: \(err)")
                    self?.usersArray = []
                } else {
                    var users = [User]()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let hostStars = data["hostStars"] as? [Int] ?? []
                        let guestStars = data["guestStars"] as? [Int] ?? []
                        let averageHostStars = hostStars.isEmpty ? 0 : Double(hostStars.reduce(0, +)) / Double(hostStars.count)
                        let averageGuestStars = guestStars.isEmpty ? 0 : Double(guestStars.reduce(0, +)) / Double(guestStars.count)
                        
                        let user = User(
                            id: document.documentID,
                            name: data["name"] as? String,
                            rating: data["rating"] as? Int,
                            comments: data["comments"] as? [String],
                            numberOfCoins: data["numberOfCoins"] as? Int,
                            isVerified: data["isVerified"] as? Bool ?? false,
                            hostRating: data["hostRating"] as? Int ?? 5,
                            guestRating: data["guestRating"] as? Int ?? 5,
                            hostStars: hostStars,
                            guestStars: guestStars,
                            hostComments: data["hostComments"] as? [String] ?? [],
                            guestComments: data["guestComments"] as? [String] ?? [],
                            averageHostStars: averageHostStars,
                            averageGuestStars: averageGuestStars,
                            stripeAccountId: data["stripeAccountId"] as? String ?? ""
                        )
                        users.append(user)
                    }
                    self?.usersArray = users
                }
            }
        }
    }
    


    
    func updateEventGuests(event: Event, currentUser: String) {
        let db = Firestore.firestore()
        guard let eventId = event.id else {
            print("Event ID is nil")
            return
        }

        let eventRef = db.collection("Events").document(eventId)

        // Use array-union to add the current user to the guestNames array
        eventRef.updateData([
            "guestNames": FieldValue.arrayUnion([currentUser])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }


    
    func updateEventCoinPrice(event: Event, priceOfCoins: Double) {
        let db = Firestore.firestore()
        guard let eventId = event.id else {
            print("Event ID is nil")
            return
        }

        let eventRef = db.collection("Events").document(eventId)

        // Update the coinPrice field in the Firestore document
        eventRef.updateData([
            "coinPrice": priceOfCoins
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    

    func signOut() {
            do {
                try Auth.auth().signOut()
                self.isLoggedIn = false
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
    func redirectToStripe(url: String) {
        if let url = URL(string: url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print(url)
                } else {
                    alertMessage = "Failed to create Stripe checkout URL."
                    showAlert = true
                }
        }
    
    func handlePaymentStatus(_ status: String) {
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
// Conform to GIDSignInDelegate


//
//  Model.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import Foundation
import FirebaseFirestore

struct User: Hashable, Identifiable, Equatable {
    
    var id: String?
    var name:String?
    var rating: Int?
    var comments: [String]?
    var numberOfCoins: Int?
    var isVerified: Bool? = false
    var hostRating:Int? = 5
    var guestRating: Int? = 5
    var hostStars: [Int]
    var guestStars: [Int]
    var hostComments :[String]
    var guestComments: [String]
    var averageHostStars:Double
    var averageGuestStars:Double
    var stripeAccountId:String?
    
    
}

struct Event: Hashable, Identifiable, Equatable {
    var id: String?
    var eventId: String
    var nameOfEvent: String
    var eventDescription: String
    var hostName: String
    var createdBy: String
    var stripeAccountId:String
    var createdDate: Timestamp
    var eventLocation: String
    var eventCoordinates:GeoPoint
    var dateOfEvent: Timestamp
    var imageUrl: String
    var maxAttendance: Int
    var costOfEntry: Int
    var ticketPriceId:String
    var ticketProductId: String
    var coinPrice: Int
    var coinPriceId: Int
    var coinProductId: String
    var isFeatured: Bool
    var hostRating:Int = 5
    var guestNames:[String]
}

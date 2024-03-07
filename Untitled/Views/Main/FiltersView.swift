//
//  FiltersView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import CoreLocation
import SwiftUI

struct FiltersView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var selectedDate = Date()
    
    @State var isDatePickerVisible = false
    
    @State var selectedDistance:Double = 1
    
    @State var selectedCost:Double = 0
    
    @State var selectedRating = 1
    
    @Binding var sheetIsPresentedFilters: Bool
    
    @State private var userLocation: CLLocationCoordinate2D?
    
    @StateObject private var locationManager = LocationManager()
    
    let customColor1 = Color(
        red: Double(132) / 255.0,
        green: Double(4) / 255.0,
        blue: Double(254) / 255.0,
        opacity: Double(255) / 255.0
    )
    
    let customColor2 = Color(
        red: Double(163) / 255.0,
        green: Double(83) / 255.0,
        blue: Double(255) / 255.0,
        opacity: Double(255) / 255.0
    )
    
    
    var body: some View {
        
        VStack {
            
            Title(subTitle: "Filters")
            
            CustomDatePicker(selectedDate: $model.selectedDate)
                .padding(.bottom, 4)
                
            
            CustomWheelPicker(selectedDistance: $model.selectedDistance)
                .onTapGesture {
                    locationManager.requestLocation()
                }
            
            NumberWheelPicker(selectedNumber: $selectedCost)
            
            ZStack {
                
                TextFrame(title: "Host Rating", text: "")
                
                ZStack {
                    Picker("Select Distance", selection: $model.selectedRating) {
                                    ForEach(1..<6, id: \.self) { stars in
                                        
                                        HStack{
                                            Text("\(stars)")
                                                .foregroundColor(.white)
                                                .font(.custom("AvenirNext", size: 15))
                                            
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.white)
                                            
                                        }
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 150, height:50)
                            
                }
                .frame(width: 140, height: 30)
                .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [customColor1, customColor2]), // Define your gradient colors
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .cornerRadius(5) // Optional: Add corner radius for rounded edges
                            )
                .padding(.leading, 135)
                
            }
            
            Button {
                sheetIsPresentedFilters = false
                
                model.filteredEventsFunc(userLocation: userLocation)
            } label: {
                CustomButton(text: "Save filters")
                    .padding(.bottom)
            }
            .buttonStyle(.plain)

           
            
            Spacer()
        }
        .onReceive(locationManager.$userLocation) { newLocation in
                   self.userLocation = newLocation
               }
        
    }
    class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
            private let locationManager = CLLocationManager()
            @Published var userLocation: CLLocationCoordinate2D?

            override init() {
                super.init()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            }

            func requestLocation() {
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestLocation()
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                if let location = locations.first {
                    DispatchQueue.main.async {
                        self.userLocation = location.coordinate
                    }
                }
            }

            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("Error getting location: \(error)")
            }
        }
    

}



struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView(sheetIsPresentedFilters: Binding.constant(true))
            .environmentObject(ContentModel())
    }
}

//distance (km)
//Cost (free or no)
//time of event - select days
//rating-- this many stars and more

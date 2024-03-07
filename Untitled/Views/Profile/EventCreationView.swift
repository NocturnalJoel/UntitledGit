//
//  EventCreationView.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-16.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MapKit

struct EventCreationView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var showingAddressInput = false
    
    @State var eventLocation = ""
    
    @State var coordinates: CLLocationCoordinate2D?
    
    @State var selectedDate = Date()
    
    @State var isDatePickerVisible = false
    
    @State var selectedTime = Date()
    
    @State var selectedDistance:Double = 1
    
    @State var selectedOption = 0
    
    @State var selectedRating = 1
    
    @State var nameOfEvent = ""
    
    @State var timeOfEvent = Date()
    
    @State var maxAttendance = "0"
    
    @State var costOfEntry = "15"
    
    @State var dateOfEvent = Date()
    
    @State var eventDescription = ""
    
    @State var coinPrice = "5"
    
    @State var showingImagePicker = false
    
    @State var inputImage: UIImage?
    
    @State var imageUrl: String?
    
    enum UploadError: Error {
        case imageNotFound
        case userIdNotFound
        case invalidImageData
        case unknownError
        case urlRetrievalError
    }

    
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
            
            Title(subTitle: "🕺 Create your Event 🗓️")
            
            ScrollView {
                
                CustomTextField(title: "Name of Event", data: $nameOfEvent)
                
                CustomTextField(title: "Event Description", data: $eventDescription)
                
                CustomDatePicker(selectedDate: $selectedDate)
                
                CustomTimePicker(selectedTime: $selectedTime)
                
                CustomTextField(title: "Max Attendance", data: $maxAttendance)
                
                CustomTextField(title: "Cost of Entry", data: $costOfEntry)
                
                CustomTextField(title: "Cost of 1 Coin", data: $coinPrice)
                
                Button {
                    showingImagePicker = true
                } label: {
                    CustomUploadPicture()
                        .accentColor(.black)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $inputImage)
                }
                .buttonStyle(.plain)
                
                ZStack {
                                   TextFrame(title: "Location", text: "")
                                   HStack {
                                       Spacer()
                                       Button(action: {
                                           showingAddressInput = true
                                       }) {
                                           ZStack {
                                               RoundedRectangle(cornerRadius: 5)
                                                   .fill(
                                                       LinearGradient(
                                                           gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing
                                                       )
                                                   )
                                                   .frame(width: 150, height: 32)
                                               
                                               Image(systemName: "mappin.and.ellipse")
                                                   .foregroundColor(.white)
                                           }
                                       }
                                       .padding(.trailing, 60)
                                       .buttonStyle(.plain)
                                   }
                               }
                .sheet(isPresented: $showingAddressInput) {
                    AddressInputView(isPresented: $showingAddressInput, eventLocation: $eventLocation, coordinates: $coordinates)
                }
                
                Button {
                    uploadImageAndSubmitEvent()
                } label: {
                    CustomButton(text: "Submit Event")
                }
                .buttonStyle(.plain)
                
            }
            
        }
        
    }
    
    
    func submitEvent() {
        // Validation for current user and event date/time
        guard let currentUser = model.currentUser else {
            print("Current user data is not available")
            return
        }
        
     

        let calendar = Calendar.current
        let combinedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let combinedTimeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        guard let eventDateTime = calendar.date(from: DateComponents(
            year: combinedDateComponents.year,
            month: combinedDateComponents.month,
            day: combinedDateComponents.day,
            hour: combinedTimeComponents.hour,
            minute: combinedTimeComponents.minute
        )), let imageUrl = imageUrl, let coordinates = coordinates else {
            print("Error: Required event information is missing")
            return
        }

        let eventId = UUID().uuidString
        
        // Prepare Firestore data
        let eventDataFirestore: [String: Any] = [
            "nameOfEvent": nameOfEvent,
            "eventDescription": eventDescription,
            "dateOfEvent": convertTimestampToString(Timestamp(date: eventDateTime)),
            "eventCoordinates": GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude),
            "maxAttendance": Int(maxAttendance) ?? 0,
            "eventLocation": eventLocation,
            "costOfEntry": Double(costOfEntry) ?? 0,
            "coinPrice": Double(coinPrice) ?? 0,
            "hostName": currentUser.name,
            "imageUrl": imageUrl,
            "eventId": eventId,
            "createdBy": currentUser.id,
            "createdDate": convertTimestampToString(Timestamp(date: Date())),
            "hostRating": currentUser.hostRating ?? 5,
            "stripeAccountId": currentUser.stripeAccountId ?? ""
        ]
        
        let eventDataStripe: [String: Any] = [
             "stripeAccountId": currentUser.stripeAccountId ?? "",
             "nameOfEvent": nameOfEvent,
             "costOfEntry": Double(costOfEntry) ?? 0,
             "coinPrice": Double(coinPrice) ?? 0,
             "maxAttendance": Int(maxAttendance) ?? 0,
             "eventId": eventId
         ]

        // Submit to Firestore
        let db = Firestore.firestore()
        db.collection("Events").document(eventId).setData(eventDataFirestore) { error in
            if let error = error {
                print("Error submitting event to Firestore: \(error.localizedDescription)")
            } else {
                print("Event successfully submitted to Firestore")

                // Convert eventDataFirestore to JSON for Stripe integration
                guard let jsonData = try? JSONSerialization.data(withJSONObject: eventDataStripe) else {
                    print("Error: Unable to encode data for Stripe")
                    return
                }

                // Create the request to Firebase Cloud Function for Stripe integration
                let url = URL(string: "https://us-central1-untitled-85526.cloudfunctions.net/createEventProducts")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                // Send the request
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error sending data to Cloud Function: \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        print("Error: Invalid response from server")
                        return
                    }

                    if let responseData = data {
                        do {
                            // Assuming Cloud Function returns JSON with a success message or error details
                            let responseDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                            if let message = responseDict?["message"] as? String {
                                print("Cloud Function response: \(message)")
                            } else {
                                print("Error: Unexpected response format from Cloud Function")
                            }
                        } catch {
                            print("Error: Failed to parse response from Cloud Function")
                        }
                    }
                }.resume()
            }
        }
    }

    


    func convertTimestampToString(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUserID = model.currentUser?.id,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(UploadError.imageNotFound))
            return
        }

        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("event_images/\(currentUserID)/\(fileName)")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error ?? UploadError.unknownError))
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error ?? UploadError.urlRetrievalError))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    func uploadImageAndSubmitEvent() {
        guard let inputImage = self.inputImage else {
            print("No image selected")
            return
        }

        uploadImage(image: inputImage) { result in
            switch result {
            case .success(let imageUrl):
                self.imageUrl = imageUrl
                self.submitEvent()
            case .failure(let error):
                print("Image upload error: \(error.localizedDescription)")
                // Handle the error appropriately
            }
        }
    }


    
    
    
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview  {
    EventCreationView()
        .environmentObject(ContentModel())
}




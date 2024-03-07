import SwiftUI
import FirebaseFirestore // Assuming this is needed for Timestamp and GeoPoint
import Combine

struct HelloDanaView: View {
    
    @EnvironmentObject var model: ContentModel
    var event: Event
    @Binding var showSheet: Bool
    var buttonText: String
    
    private let imageHeight: CGFloat = 100 // Height for the image
    private let totalViewHeight: CGFloat = 335 // Total height of the HelloDanaView
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [model.customColor1, model.customColor2]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: totalViewHeight * 0.7)
                    .shadow(radius: 10)
                
                VStack {
                    URLImageView(url: event.imageUrl)
                    
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.nameOfEvent)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(event.eventDescription)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        
                        
                        Text(isCurrentUserAGuest() ? event.eventLocation : extractCity(from: event.eventLocation))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack {
                            Text("Max: \(event.maxAttendance)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("$\(event.costOfEntry)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        HStack {
                            ForEach(0..<event.hostRating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        model.selectedEvent = event
                        showSheet = true
                    }) {
                        Text(buttonText)
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                Capsule()
                                    .stroke(LinearGradient(gradient: Gradient(colors: [model.customColor1, model.customColor2]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                            )
                            .foregroundColor(model.customColor1)
                            .cornerRadius(40)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .buttonStyle(.plain)
                }
            }
            .cornerRadius(20)
            .padding(.horizontal)
        }
        .frame(height: totalViewHeight)
        .sheet(isPresented: $showSheet) {
            
            ReservationView(event: model.selectedEvent!)
            
        }
    }
    
    private func extractCity(from address: String) -> String {
        let components = address.components(separatedBy: ",")
        // Assuming the city is always the second component of the address
        // Adjust the index if necessary
        return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
    }
    
    private func isCurrentUserAGuest() -> Bool {
        // Assuming guestNames is an array of strings and currentUser.name is a string
        return event.guestNames.contains((model.currentUser?.name)!)
    }
    
    
}
    // Assuming other structs like URLImageView, etc., are defined elsewhere
    
    
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        private var cancellable: AnyCancellable?
        
        func loadImage(from url: String) {
            guard let imageURL = URL(string: url) else {
                return
            }
            
            cancellable = URLSession.shared.dataTaskPublisher(for: imageURL)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in self?.image = $0 })
        }
        
        deinit {
            cancellable?.cancel()
        }
    }
    struct URLImageView: View {
        @StateObject private var loader = ImageLoader()
        
        let url: String
        
        var body: some View {
            Group {
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                } else {
                    // Placeholder or Loading View
                    Rectangle().foregroundColor(.gray)
                        .border(Color.blue, width: 1)
                }
            }
            .onAppear {
                loader.loadImage(from: url)
            }
        }
    }
    


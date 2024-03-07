import SwiftUI
enum HostSheet: Identifiable {
    case listOfGuests, eventCreation
    
    var id: Int {
        hashValue
    }
}

struct HostView: View {
    
    
    @EnvironmentObject var model:ContentModel
    
    @State var activeSheet: HostSheet?
    
    @State private var selectedEvent: Event?
    
    @State var shutUp = false
    
    var body: some View {
        
        if model.currentUser!.isVerified! {
            
            Button {
                activeSheet = .eventCreation
            } label: {
                CustomButton(text: "Create Event")
            }
            .buttonStyle(.plain)
        } else if model.currentUser!.isVerified == false {
            
            NavigationLink(destination: VerifyHostView().environmentObject(model)) {
                                    CustomButton(text: "Become a Host")
                                }
            
        }
        
        
        ScrollView {
            VStack {
                ForEach(model.allEvents.filter { $0.createdBy == model.currentUser?.id }, id: \.id) { event in
                    // This is the view you want to repeat 5 times
                    Button {
                        selectedEvent = event
                        activeSheet = .listOfGuests
                    } label: {
                        
                        HelloDanaView(event: event, showSheet: $shutUp, buttonText: "See Guests" )
                        
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top)
        .sheet(item: $activeSheet) { item in
            switch item {
            case .listOfGuests:
                if let selectedEvent = selectedEvent {
                    ListOfGuestsView(selectedEvent: selectedEvent)
                        .environmentObject(model)
                }
            case .eventCreation:
                EventCreationView()
                
            
            }
        }
    }
}

struct HostView_Previews: PreviewProvider {
    static var previews: some View {
        HostView()
            .environmentObject(ContentModel())
    }
}

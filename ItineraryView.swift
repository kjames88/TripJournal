//
//  ItineraryView.swift
//  TripJournal
//
//  Created by Kevin James on 7/21/25.
//

import SwiftUI

struct ItineraryView: View {
    @State var addAction: () -> Void = {}

    enum Mode: Identifiable {
        case add
        case edit(TravelSegment)
        
        var id: String {
            switch self {
            case .add:
                return "TransitForm.add"
            case let .edit(segment):
                return "TransitForm.edit: \(segment.id)"
            }
        }
    }

    init(segments: [TravelSegment]) {
        self.segments = segments
        self.addAction = {}
    }
    
    @State private var mode: Mode?
    @State private var newSegment = TravelSegment(id: UUID(), name: "Template", startDate: Date(), endDate: Date(), startLocation: nil, endLocation: nil)
    @State private var segments: [TravelSegment]
    
    var body: some View {
        VStack {
            Text("Travel Itinerary")
                .font(.title)
            Spacer()
            ScrollView {
                ForEach(segments) { segment in
                    TransitView(segment: segment)
                }
                Spacer()
            }
            Spacer()
            AddButton(action: {
                self.mode = .add}
            )
        }
        .onAppear {
            addAction = { mode = .add }
        }
        .sheet(item: $mode) { mode in
            TransitForm(mode: mode, segment: $newSegment, onSave: { x in
                segments.append(x)
            })
        }
    }    
}

#Preview {
    ItineraryView(segments: [
        TravelSegment(id: UUID(), name: "Fly to Paris", startDate: Date(), endDate: Date(), startLocation: Location(latitude: 0, longitude: 0), endLocation: Location(latitude: 0, longitude: 0)),
        TravelSegment(id: UUID(), name: "Train to Nice", startDate: Date(), endDate: Date(), startLocation: Location(latitude: 0, longitude: 0), endLocation: Location(latitude: 0, longitude: 0)),
         TravelSegment(id: UUID(), name: "Drive to Nimes", startDate: Date(), endDate: Date(), startLocation: Location(latitude: 0, longitude: 0), endLocation: Location(latitude: 0, longitude: 0)),
         TravelSegment(id: UUID(), name: "Train to Paris", startDate: Date(), endDate: Date(), startLocation: Location(latitude: 0, longitude: 0), endLocation: Location(latitude: 0, longitude: 0))
        ])
}

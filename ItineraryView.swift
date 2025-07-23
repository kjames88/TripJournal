//
//  ItineraryView.swift
//  TripJournal
//
//  Created by Kevin James on 7/21/25.
//

import SwiftUI

struct ItineraryView: View {
    enum Mode {
        case add
        case edit(TravelSegment)
    }

    init(segments: [TravelSegment]) {
        self.segments = segments
    }
    
    @State private var mode: Mode?
    @State private var segments: [TravelSegment]
    
    var body: some View {
        VStack {
            Text("Travel Itinerary")
                .font(.title)
            Spacer()
            ForEach(segments) { segment in
                Text(segment.name)
            }
            Spacer()
        }
    
    }
}

#Preview {
    ItineraryView(segments: [TravelSegment(id: 1, name: "Fly to Paris", startDate: Date(), endDate: nil, startLocation: Location(latitude: 0, longitude: 0), endLocation: Location(latitude: 0, longitude: 0))])
}

//
//  ItineraryView.swift
//  TripJournal
//
//  Created by Kevin James on 7/21/25.
//

import SwiftUI

struct ItineraryView: View {
    @State var addAction: () -> Void = {}
    @State var defaultSegment: TravelSegment = .init(id: UUID(), name: "", startDate: Date(), endDate: Date(), startLocation: nil, endLocation: nil)

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
    @State private var segments: [TravelSegment]
    
    var body: some View {
        VStack {
            Text("Travel Itinerary")
                .font(.title)
            Spacer()
            ScrollView {
                ForEach($segments) { $segment in
                    TransitView(segment: $segment, edit: {
                        self.defaultSegment = segment
                        self.mode = .edit(segment)
                    })
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
            if case .add = mode {
                TransitForm(mode: mode, segment: $defaultSegment, onSave: { seg in
                    segments.append(seg)
                })
            } else if case .edit(let editSegment) = mode {
                TransitForm(mode: mode, segment: $defaultSegment, onSave: { seg in
                    if let idx = segments.firstIndex(of: editSegment) {
                        segments[idx] = seg
                    }
                })
            }
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

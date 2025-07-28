//
//  TransitView.swift
//  TripJournal
//
//  Created by Kevin James on 7/20/25.
//

import SwiftUI
import MapKit

struct TransitView: View {
    // From ChatGPT:  @Binding is necessary to create a read-write reference
    //   @State is only for local data (useful when this View manages this data)
    // @State does NOT trigger update to the view when segment is changed in ItineraryView
    //   unless the id field is replaced.
    @Binding var segment: TravelSegment
    let edit: () -> Void
   
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            // From ChatGPT:
            // The ZStack alignment of .trailing ensures that views that don’t take the full width (like the Button) will be anchored to the trailing side.
            ZStack(alignment: .trailing) {
                nameLabel
                Button("Edit", systemImage: "pencil", action: edit)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.bordered)
                    .font(.callout)
            }
            .padding()
            startDateLocationLabel
            endDateLocationLabel
            Spacer()
        }
    }
    
    private var dateLabel: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(segment.startDate, style: .date)
            Text("-")
            Text(segment.endDate, style: .date)
        }
        .font(.footnote)
    }
    
    private var nameLabel: some View {
        Text(segment.name)
            .font(.title2)
            .frame(maxWidth: .infinity)
    }
       
    private var startDateLocationLabel: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                Spacer()
                Text("Departing")
                Text(segment.startDate, style: .date)
                Spacer()
                Text(segment.startDate, style: .time)
                Spacer()
            }
            if let location = segment.startLocation {
                map(for: location)
            }
        }
    }

    private var endDateLocationLabel: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                Spacer()
                Text("Arriving")
                Text(segment.endDate, style: .date)
                Spacer()
                Text(segment.endDate, style: .time)
                Spacer()
            }
            if let location = segment.endLocation {
                map(for: location)
            }
        }
    }

    @ViewBuilder
    func map(for location: Location) -> some View {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 0, longitudinalMeters: 0)
        let bounds = MapCameraBounds(centerCoordinateBounds: region, minimumDistance: 250, maximumDistance: .infinity)

        Map(bounds: bounds) {
            Marker(location.address ?? "", coordinate: location.coordinate)
        }
        .mapStyle(.standard(elevation: .realistic))
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
    }
}

#Preview {
    TransitView(segment: .constant(TravelSegment(id: UUID(), name: "Fly to Paris", startDate: Date(), endDate: Date(), startLocation: Location(latitude: 37.7749, longitude: -122.4194), endLocation: Location(latitude: 48.8575, longitude: 2.3514))), edit: {})
}

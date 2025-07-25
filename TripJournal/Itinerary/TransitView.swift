//
//  TransitView.swift
//  TripJournal
//
//  Created by Kevin James on 7/20/25.
//

import SwiftUI
import MapKit

struct TransitView: View {
    @State private var segment: TravelSegment
    
    init(segment: TravelSegment) {
        self.segment = segment
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            nameLabel
            Spacer()
            startDateLocationLabel
            endDateLocationLabel
            Spacer()
        }
    }
    
    private var dateLabel: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(segment.startDate, style: .date)
            Text("-")
            Text(segment.endDate ?? segment.startDate, style: .date)
        }
        .font(.footnote)
    }
    
    private var nameLabel: some View {
        Text(segment.name)
            .font(.title2)
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
            map(for: segment.startLocation)
        }
    }

    private var endDateLocationLabel: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                Spacer()
                Text("Arriving")
                Text(segment.endDate ?? segment.startDate, style: .date)
                Spacer()
                Text(segment.endDate ?? segment.startDate, style: .time)
                Spacer()
            }
            map(for: segment.endLocation)
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
    TransitView(segment: TravelSegment(id: 1, name: "Fly to Paris", startDate: Date(), endDate: nil, startLocation: Location(latitude: 37.7749, longitude: -122.4194), endLocation: Location(latitude: 48.8575, longitude: 2.3514)))
}

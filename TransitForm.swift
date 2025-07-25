//
//  TransitForm.swift
//  TripJournal
//
//  Created by Kevin James on 7/22/25.
//

import SwiftUI
import MapKit

struct TransitForm: View {
    @State private var mode: ItineraryView.Mode
    @State private var segment: TravelSegment?
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isLocationPickerPresented: Bool = false
    @State private var selectStartLocation = true
    @State private var startLocation: Location?
    @State private var endLocation: Location?

    @Environment(\.dismiss) private var dismiss

    init(mode: ItineraryView.Mode, segment: TravelSegment? = nil) {
        self.mode = mode
        self.segment = segment
    }
    
    var body: some View {
        Form {
            Section("Travel Segment") {
                TextField("Name", text: $name)
            }
            Section("Departure") {
                DatePicker("Depart", selection: $startDate)
            }
            locationSection(isStart: true)
            Section("Arrival") {
                DatePicker("Arrive", selection: $endDate)
            }
            locationSection(isStart: false)
        }
        .sheet(isPresented: $isLocationPickerPresented) {
            LocationPicker(location: selectStartLocation ? startLocation : endLocation) { selectedLocation in
                if selectStartLocation {
                    startLocation = selectedLocation
                } else {
                    endLocation = selectedLocation
                }
            }
        }
        Button("Save") {
            segment = TravelSegment(id: 1, name: name, startDate: startDate, endDate: endDate, startLocation: startLocation!, endLocation: endLocation!)
        }
    }
    
    @ViewBuilder
    private func locationSection(isStart: Bool) -> some View {
        let location = isStart ? startLocation : endLocation
        Section {
            if let location {
                Button(
                    action: { isLocationPickerPresented = true },
                    label: {
                        map(location: location)
                    }
                )
                .buttonStyle(.plain)
                .containerRelativeFrame(.horizontal)
                .clipped()
                .listRowInsets(EdgeInsets())
                .frame(height: 150)

                removeLocation(isStart: isStart)
            } else {
                addLocation(isStart: isStart)
            }
        }
    }
    
    private func addLocation(isStart: Bool) -> some View {
        Button(
            action: {
                isLocationPickerPresented = true
                selectStartLocation = isStart
            },
            label: {
                Text("Add Location")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
    }

    private func removeLocation(isStart: Bool) -> some View {
        Button(
            role: .destructive,
            action: {
                if isStart {
                    startLocation = nil
                } else {
                    endLocation = nil
                }
            },
            label: {
                Text("Remove Location")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
    }
       
    @ViewBuilder
    private func map(location: Location) -> some View {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 0, longitudinalMeters: 0)
        let bounds = MapCameraBounds(centerCoordinateBounds: region, minimumDistance: 250, maximumDistance: .infinity)

        Map(bounds: bounds) {
            Marker(location.address ?? "", coordinate: location.coordinate)
        }
    }
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Dismiss", systemImage: "xmark") {
                dismiss()
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                switch mode {
                case .add:
                    Task {
                    }
                case let .edit(segment):
                    Task {
                    }
                }
            }
        }
    }
}

#Preview {
    TransitForm(mode: .add)
}

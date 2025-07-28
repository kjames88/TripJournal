//
//  TransitForm.swift
//  TripJournal
//
//  Created by Kevin James on 7/22/25.
//

import SwiftUI
import MapKit

struct TransitForm: View {
    var mode: ItineraryView.Mode
    @Binding var segment: TravelSegment
    let onSave: (TravelSegment) -> Void
    
    @State private var isLocationPickerPresented: Bool = false
    @State private var selectStartLocation = true

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Travel Segment") {
                TextField("Name", text: $segment.name)
            }
            Section("Departure") {
                DatePicker("Depart", selection: $segment.startDate)
                departureLocation()
            }
            Section("Arrival") {
                DatePicker("Arrive", selection: $segment.endDate)
                destinationLocation()
            }
        }
        .sheet(isPresented: $isLocationPickerPresented) {
            let displayLocation = selectStartLocation ? segment.startLocation : segment.endLocation
            LocationPicker(location: displayLocation) { selectedLocation in
                segment.startLocation = selectStartLocation ? selectedLocation : segment.startLocation
                segment.endLocation = selectStartLocation ? segment.endLocation : selectedLocation
            }
        }
        HStack {
            Spacer()
            Button("Save") {
                switch mode {
                case .add:
                    segment.id = UUID()
                default:
                    break
                }
                onSave(segment)
                dismiss()
            }
            Spacer()
            Button("Cancel") {
                dismiss()
            }
            Spacer()
        }
    }

    
    @ViewBuilder
    private func departureLocation() -> some View {
        if let location = segment.startLocation {
            Button(
                action: {
                    selectStartLocation = true
                    isLocationPickerPresented = true
                },
                label: {
                    map(location: location)
                }
            )
            .buttonStyle(.plain)
            .containerRelativeFrame(.horizontal)
            .clipped()
            .listRowInsets(EdgeInsets())
            .frame(height: 150)
            
            editLocation(isStart: true)
            removeLocation(isStart: true)
        } else {
            addLocation(isStart: true)
        }
    }
    
    @ViewBuilder
    private func destinationLocation() -> some View {
        if let location = segment.endLocation {
            Button(
                action: {
                    selectStartLocation = false
                    isLocationPickerPresented = true
                },
                label: {
                    map(location: location)
                }
            )
            .buttonStyle(.plain)
            .containerRelativeFrame(.horizontal)
            .clipped()
            .listRowInsets(EdgeInsets())
            .frame(height: 150)
            
            editLocation(isStart: false)
            removeLocation(isStart: false)
        } else {
            addLocation(isStart: false)
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

    private func editLocation(isStart: Bool) -> some View {
        Button(
            action: {
                isLocationPickerPresented = true
                selectStartLocation = isStart
            },
            label: {
                Text("Edit Location")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
    }
    
    private func removeLocation(isStart: Bool) -> some View {
        Button(
            role: .destructive,
            action: {
                if isStart {
                    segment.startLocation = nil
                } else {
                    segment.endLocation = nil
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
}

#Preview {
    @Previewable @State var segment: TravelSegment = TravelSegment(id: UUID(), name: "Fly to Paris", startDate: Date(), endDate: Date(), startLocation: nil, endLocation: nil)
    TransitForm(mode: .add, segment: $segment, onSave: {_ in })
}

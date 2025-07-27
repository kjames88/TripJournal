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
    
    //@State private var name: String = ""
    //@State private var startDate: Date = Date()
    //@State private var endDate: Date = Date()
    @State private var isLocationPickerPresented: Bool = false
    @State private var selectStartLocation = true
    //@State private var startLocation: Location?
    //@State private var endLocation: Location?

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
            LocationPicker(location: selectStartLocation ? segment.startLocation : segment.endLocation) { selectedLocation in
                if selectStartLocation {
                    segment.startLocation = selectedLocation
                } else {
                    segment.endLocation = selectedLocation
                }
            }
        }
        Button("Save") {
            switch mode {
            case .add: segment.id = UUID()
                break
            case .edit: break
            }
            
            onSave(segment)
            dismiss()
        }
    }
    
//    @ViewBuilder
//    private func locationSection(isStart: Bool) -> some View {
//        let location = isStart ? segment.startLocation : segment.endLocation
//        if let location = location {
//            //Section {
//                Button(
//                    action: { isLocationPickerPresented = true },
//                    label: {
//                        map(location: location)
//                    }
//                )
//                .buttonStyle(.plain)
//                .containerRelativeFrame(.horizontal)
//                .clipped()
//                .listRowInsets(EdgeInsets())
//                .frame(height: 150)
//                
//                editLocation(isStart: isStart)
//                removeLocation(isStart: isStart)
//            //}
//        } else {
//            addLocation(isStart: isStart)
//        }
//    }
    
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
                    segment.startLocation = Location(latitude: 0, longitude: 0)
                } else {
                    segment.endLocation = Location(latitude: 0, longitude: 0)
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

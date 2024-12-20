//
//  DonationMapView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import MapKit
import SwiftUI

struct DonationMapView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @StateObject var mapVM: MapViewModel = MapViewModel()

    var body: some View {
        ZStack {
            Map(position: $mapVM.position) {
                //                if let donations = donVM.donations {
                //                    ForEach(donations, id: \.id) { donation in
                //                        Marker(donation.title, coordinate: .init(latitude: donation.location.lat, longitude: donation.location.long))
                //                    }
                //                }
                //                if let coordinates = mapVM.coordinates {
                //                    Marker(mapVM.searchTerm, coordinate: coordinates)
                //
                //                }
                if let coordinates = mapVM.coordinates {
                    Marker("Meine Position", coordinate: coordinates)
                }

                if let donations = donVM.donations {
                    ForEach(donations, id: \.id) { donation in
                        
                        Annotation(donation.title, coordinate: CLLocationCoordinate2D(latitude: donation.location.lat, longitude: donation.location.long)) {
                            Image("fridgeicon2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 32)
                                .foregroundStyle(Color("primaryAT"))
                            Text(donation.title)
                                .font(.caption)
                                .foregroundStyle(Color("primaryAT"))
                        }
                        .annotationTitles(.hidden)
                        
                        Marker(
                            donation.title,
                            coordinate: .init(
                                latitude: donation.location.lat,
                                longitude: donation.location.long))
                    }
                }
//                ForEach(mapVM.locationsInRadius) { location in
//                    Annotation(location.name, coordinate: location.coordinate) {
//                        Image("fridgeicon2")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 32)
//                            .foregroundStyle(Color("primaryAT"))
//                        Text(location.name)
//                            .font(.caption)
//                            .foregroundStyle(Color("primaryAT"))
//                    }
//                    .annotationTitles(.hidden)
//
//                }

                if let coordinates = mapVM.coordinates {
                    MapCircle(center: coordinates, radius: mapVM.searchRadius)
                        .strokeStyle(style: .init(lineWidth: 2))
                        .foregroundStyle(.green.opacity(0.25))
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapScaleView()
                MapCompass()
                MapUserLocationButton()
                MapPitchToggle()
            }

            VStack {
                HStack {
                    TextField("Suche:", text: $mapVM.searchTerm)
                        .padding(8)
                        .background(Color("primaryContainer"))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10))
                    Button("Start") {
                        mapVM.getCoordinates()
                    }
                    .primaryButtonStyle()
                }
                Spacer()
                VStack {
                    HStack {
                        Text("100 M")
                            .font(.system(size: 10))
                        Slider(value: $mapVM.searchRadius, in: 100...5000) {
                            _ in
                            mapVM.updateLocationsInRadius()
                        }
                        .tint(Color("primaryAT"))

                        Text("5 KM")
                            .font(.system(size: 10))

                    }
                    Text("\(Int(mapVM.searchRadius)) M")
                        .font(.system(size: 10))
                }
            }
            .padding()

        }
        .task {
            mapVM.requestLocation()
        }

    }
}

#Preview {
    DonationMapView()
        .environmentObject(DonationViewModel())
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

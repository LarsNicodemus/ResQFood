//
//  MapView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapVM: MapViewModel
    
    var body: some View {
        Map(position: $mapVM.position) {

            if let coordinates = mapVM.coordinates {
                Annotation("Meine Position", coordinate: coordinates) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                        .foregroundStyle(Color("primaryContainer"))
                        .overlay {
                            Image(systemName: "heart")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("primaryAT"))
                        }

                    Text("Meine Position")
                        .font(.caption)
                        .foregroundStyle(Color("primaryAT"))
                }
                .annotationTitles(.hidden)
            }
            if !mapVM.locationsInRadius.isEmpty {

                if let donations = mapVM.donations, !donations.isEmpty {
                    ForEach(donations, id: \.id) { donation in
                        Annotation(
                            donation.title,
                            coordinate: CLLocationCoordinate2D(
                                latitude: donation.location.lat,
                                longitude: donation.location.long
                            )
                        ) {
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
                    }
                }
            }

            if let coordinates = mapVM.coordinates {
                MapCircle(
                    center: coordinates, radius: mapVM.searchRadius
                )
                .strokeStyle(style: .init(lineWidth: 2))
                .foregroundStyle(.green.opacity(0.25))
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapScaleView()
            MapCompass()
            MapPitchToggle()
        }
    }
}


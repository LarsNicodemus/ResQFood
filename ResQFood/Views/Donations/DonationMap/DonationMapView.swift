//
//  DonationMapView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import MapKit
import SwiftUI

struct DonationMapView: View {
    @ObservedObject var mapVM: MapViewModel

    var body: some View {
        ZStack {
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
                let donations = mapVM.locationsInRadius
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
                    }
                }

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
                MapPitchToggle()
            }

            VStack {
                HStack {
                    TextField("Suche:", text: $mapVM.searchTerm)
                        .padding(8)
                        .background(Color("primaryContainer").opacity(0.5))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("primaryAT"),lineWidth: 1)
                                
                        }
                    Button("Start") {
                        mapVM.coordinates = nil
                        mapVM.getCoordinates()
                    }
                    .primaryButtonStyle()
                    Button {
                        mapVM.coordinates = nil
                        mapVM.resetLocation()
                        mapVM.searchTerm = ""
                    } label: {
                        Image(systemName: "location.fill")
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
            .padding(.top, 64)
            .padding(.horizontal, 8)
        }
        .task {
            mapVM.requestLocation()
        }

    }
}

#Preview {
    DonationMapView(mapVM: MapViewModel())
}



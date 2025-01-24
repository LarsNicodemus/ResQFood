//
//  DonationMapView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import MapKit
import SwiftUI

struct DonationMapView: View {
    @EnvironmentObject var mapVM: MapViewModel

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

                        Annotation(
                            donation.title,
                            coordinate: CLLocationCoordinate2D(
                                latitude: donation.location.lat,
                                longitude: donation.location.long)
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
                            RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("primaryAT"), lineWidth: 1)
                        }
                        .onSubmit {
                            mapVM.updateSearchResults()
                        }

                    Button {
                        mapVM.coordinates = nil
                        mapVM.startPressed = false
                        mapVM.resetLocation()
                        mapVM.searchTerm = ""
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .primaryButtonStyle()
                }

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
                        if !mapVM.filerToggle {
                            Button("Filter") {
                                mapVM.filerToggle.toggle()
                            }
                            .primaryButtonStyle()
                        }

                    }
                    Text("\(Int(mapVM.searchRadius)) M")
                        .font(.system(size: 10))

                }
                
                Spacer()
                VStack {

                    DonationListView(mapVM: mapVM)
                        .frame(minHeight: 0, maxHeight: 350, alignment: .bottom)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("secondaryContainer").opacity(0.5)))
                }
            }
            .padding(.top, 64)
            .padding(.horizontal, 8)
            if mapVM.filerToggle {
                ZStack{
                    FilterView()
                        .frame(maxWidth: 250, maxHeight: 300)
                        .padding(.trailing, 8)
                        .padding(.top, 106)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .task {

            mapVM.requestLocation()

        }
        .onChange(of: mapVM.searchRadius) { oldValue, newValue in
            if let coordinates = mapVM.coordinates {
                withAnimation {
                    mapVM.position = .region(
                        MKCoordinateRegion(
                            center: coordinates,
                            latitudinalMeters: newValue * 2,
                            longitudinalMeters: newValue * 2
                        ))
                }
            }
        }

    }
}

#Preview {
    DonationMapView()
        .environmentObject(MapViewModel())
}

struct FilterView: View {
    @EnvironmentObject var mapVM: MapViewModel

    var body: some View {
        VStack {
            HStack {
                Button("Löschen") {
                    print("Ausgewählt: \(mapVM.selectedItems)")
                    mapVM.selectedItems = []

                }
                .primaryButtonStyle()
                Spacer()
                Button("Fertig") {
                    print("Ausgewählt: \(mapVM.selectedItems)")
                    mapVM.filerToggle.toggle()
                }
                .primaryButtonStyle()
            }
            
            List(
                GroceryType.allCases,
                id: \.self,
                selection: $mapVM.selectedItems
            ) { item in
                Text(item.rawValue)
                    .tag(item)
                    .listRowBackground(
                        mapVM.selectedItems.contains(item)
                            ? Color("tertiaryContainer").opacity(0.2)
                            : Color("secondaryContainer")
                    )
                    .foregroundColor(
                        mapVM.selectedItems.contains(item)
                            ? Color("OnTertiaryContainer")
                            : Color("OnSecondaryContainer")
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("primaryAT"), lineWidth: 1)
            }
            .environment(\.editMode, .constant(.active))
            .accentColor(Color("primaryAT"))
            .listStyle(InsetGroupedListStyle())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            
        }
        .padding(8)
        .background(Color("secondaryContainer"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("primaryAT"), lineWidth: 1)
        }
        
    }
}

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
            if mapVM.isLoading {
                ProgressView("Lade Spenden...")
            } else {
                MapView()
            }
            MapInputListView()
            if mapVM.filerToggle {
                ZStack {
                    FilterView()
                        .frame(maxWidth: 250, maxHeight: 300)
                        .padding(.trailing, 8)
                        .padding(.top, 106)
                }
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .topTrailing)
            }
        }
        .onAppear {
            mapVM.requestLocation()
        }
        .onChange(of: mapVM.searchRadius) { oldValue, newValue in
            if let coordinates = mapVM.coordinates {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        mapVM.position = .region(
                            MKCoordinateRegion(
                                center: coordinates,
                                latitudinalMeters: newValue * 2,
                                longitudinalMeters: newValue * 2
                            )
                        )
                    }
                }
            }
        }

    }
}

#Preview {
    DonationMapView()
        .environmentObject(MapViewModel())
}


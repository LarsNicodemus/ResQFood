//
//  MapInputListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct MapInputListView: View {
    @EnvironmentObject var mapVM: MapViewModel

    var body: some View {
        
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
                    mapVM.resetLocation()
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
                
                DonationListView()
                    .frame(minHeight: 0, maxHeight: 350, alignment: .bottom)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("secondaryContainer").opacity(0.5)))
                
            }
        }
        .padding(.top, 64)
        .padding(.horizontal, 8)
    }
}



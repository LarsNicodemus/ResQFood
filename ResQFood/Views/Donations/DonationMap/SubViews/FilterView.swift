//
//  FilterView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

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


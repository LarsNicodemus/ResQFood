//
//  CreateView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import PhotosUI
import SwiftUI

struct CreateView: View {
    @StateObject var donVM: DonationViewModel = DonationViewModel()
    @StateObject var locVM: LocationViewModel = LocationViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                TextField("Titel", text: $donVM.title)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                TextField("Beschreibung", text: $donVM.description)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack {
                    Text("Typ:")
                    Picker(
                        "Typ auswählen", selection: $donVM.selectedType
                    ) {
                        ForEach(GroceryType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 220, height: 100)
                }
                HStack {
                    TextField("Gewicht / Volumen", text: $donVM.weightInputText)
                        .frame(width: 180, height: 30)
                        .padding(8)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .keyboardType(.decimalPad)
                    Picker(
                        "Einheit auswählen",
                        selection: $donVM.selectedWeightUnit
                    ) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                                .font(.caption)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 100, height: 100)

                }

                VStack(alignment: .leading) {
                    Text("MHD:")
                        .padding(.leading, 12)

                    DatePicker(
                        selection: $donVM.bbd, displayedComponents: .date
                    ) {}
                    .frame(width: 100, height: 30)
                    .environment(\.locale, Locale(identifier: "de-DE"))
                    .padding(.trailing, 18)
                }

                HStack {
                    Text("Zustand:")
                    Picker(
                        "Zustand auswählen",
                        selection: $donVM.selectedItemCondition
                    ) {
                        ForEach(ItemCondition.allCases, id: \.self) {
                            condition in
                            Text(condition.rawValue).tag(condition)
                                .font(.caption)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 120, height: 100)
                }
                VStack(alignment: .leading) {
                    Text("Gültig bis:")
                        .padding(.leading, 12)

                    DatePicker(
                        selection: $donVM.expiringDate,
                        displayedComponents: .date
                    ) {}
                    .frame(width: 100, height: 30)
                    .environment(\.locale, Locale(identifier: "de-DE"))
                    .padding(.trailing, 18)
                }
                HStack {
                    Text("Bevorzugte Übergabe:")
                    Picker(
                        "Übergabe auswählen",
                        selection: $donVM.selectedPreferredTransfer
                    ) {
                        ForEach(PreferredTransfer.allCases, id: \.self) {
                            transfer in
                            Text(transfer.rawValue).tag(transfer)
                                .font(.caption)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 120, height: 100)
                }
                
                TextField("Adresse:", text: $locVM.address)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

        }
        .onChange(of: donVM.weightInputText) { old, new in
            donVM.weight = donVM.convertWeight(donVM.weightInputText)
        }
    }
}

#Preview {
    CreateView()
}

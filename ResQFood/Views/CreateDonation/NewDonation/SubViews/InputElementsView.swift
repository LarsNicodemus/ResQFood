//
//  InputElementsView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//

import SwiftUI

struct InputElementsView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var locVM: LocationViewModel
    @State var showToast: Bool = false
    @State var updateSuccess: Bool = false
    var proxy: ScrollViewProxy
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                ImagePickUploadView()
                    .id("scrollContent")
                Spacer()
            }
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
                            .primaryPickerStyle(width: 220, height: 25)

                    }
                }
                .pickerStyle(.inline)
                .frame(width: 220, height: 100)
            }
            HStack {
                TextField(
                    "Gewicht / Volumen", text: $donVM.weightInputText
                )
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
                            .primaryPickerStyle(width: 100, height: 25)

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
                            .primaryPickerStyle(width: 120, height: 25)
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
                Text("Bevorzugter Treffpunkt:")
                Picker(
                    "Übergabe auswählen",
                    selection: $donVM.selectedPreferredTransfer
                ) {
                    ForEach(PreferredTransfer.allCases, id: \.self) {
                        transfer in
                        Text(transfer.rawValue).tag(transfer)
                            .primaryPickerStyle(width: 120, height: 25)
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

            HStack {
                Spacer()
                Button("Spende erstellen") {
                    let checkUpdate = donVM.checkForDonationUpload()
                    withAnimation {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                    if checkUpdate {
                        updateSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                donVM.isPresent = false
                            }
                        }
                    } else {
                        updateSuccess = false
                        withAnimation {
                            proxy.scrollTo("scrollContent")
                        }

                    }

                }
                .primaryButtonStyle()

                Spacer()
            }
            .padding(.bottom, 48)
        }
        .overlay(
            Group {
                if showToast {
                    if updateSuccess {
                        ToastView(
                            message: "Spende erstellt!"
                        )
                    } else {
                        ToastView(
                            message: "da fehlt noch etwas!"
                        )
                    }

                }
            }
        )
        .onChange(of: donVM.uploadSuccess) { error, success in
            if success {
                withAnimation {
                    donVM.showToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        donVM.showToast = false
                    }
                }

            }
        }
        .onChange(of: locVM.address) { old, new in
            locVM.fetchCoordinates()
            if let lat = locVM.geoCodingM.latitude,
                let long = locVM.geoCodingM.longitude
            {
                donVM.location.lat = lat
                donVM.location.long = long
                print(String(lat))
                print(String(long))
            }

        }
        .onChange(of: donVM.weightInputText) { old, new in
            donVM.weight = donVM.convertWeight(donVM.weightInputText)
        }
    }
}

//
//  InputElementsView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//

import SwiftUI

struct InputElementsView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var mapVM: MapViewModel

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
            if let titleError = donVM.titleError {
                Text(titleError)
                    .font(.caption)
                    .foregroundStyle(Color("error"))
            }
                TextField("Titel", text: $donVM.title)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            
            if let descriptionError = donVM.descriptionError {
                Text(descriptionError)
                    .font(.caption)
                    .foregroundStyle(Color("error"))
            }
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
                VStack{
                    if let weightError = donVM.weightError {
                        Text(weightError)
                            .font(.caption)
                            .foregroundStyle(Color("error"))
                    }
                    TextField(
                        "Gewicht / Volumen", text: $donVM.weightInputText
                    )
                    .frame(width: 180, height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .keyboardType(.decimalPad)
                }
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
            if let locationError = donVM.locationError {
                Text(locationError)
                    .font(.caption)
                    .foregroundStyle(Color("error"))
            }
            TextField("Adresse:", text: $donVM.address)
                .frame(height: 30)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom)
            HStack {
                Spacer()
                Button("Spende erstellen") {
                    Task {
                        let checkUpdate = await donVM.checkForDonationUpload()
                        if checkUpdate {                            
                            updateSuccess = true
                            withAnimation {
                                showToast = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                    donVM.resetDonationFields()
                                    imageVM.resetFields()
//                                    donVM.isPresent = false
                                }
                            }
                        } else {
                            updateSuccess = false
                            withAnimation {
                                showToast = true
                                proxy.scrollTo("scrollContent")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                }
                            }
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
                            message: "Da fehlt noch etwas!"
                        )
                    }

                }
            }
        )
        .onAppear{
            Task {
                await donVM.getUserProfileByID()
            }
        }
        .onChange(of: donVM.address) { old, new in
                Task {
                    if let coordinates = await mapVM.getCoordinatesFromAddress(new) {
                        donVM.location.lat = coordinates.latitude
                        donVM.location.long = coordinates.longitude
                    }
                }
            }
        .onChange(of: donVM.weightInputText) { old, new in
            donVM.weight = donVM.convertWeight(donVM.weightInputText)
        }
    }
}

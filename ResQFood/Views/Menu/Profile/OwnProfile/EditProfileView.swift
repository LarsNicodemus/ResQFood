//
//  EditProfileView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                TextField("Username eingeben:", text: $profileVM.username)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack {
                    Text("Geburtsdatum:")
                        .padding(.leading, 12)

                    DatePicker(
                        selection: $profileVM.birthDay, displayedComponents: .date
                    ) {}
                    .frame(width: 100, height: 30)
                    .environment(\.locale, Locale(identifier: "de-DE"))
                    .padding(.trailing, 18)
                }
                HStack {
                    Text("Sie sind:")
                    Picker(
                        "Zustand auswählen",
                        selection: $profileVM.selectedGender
                    ) {
                        ForEach(Gender.allCases, id: \.self) {
                            gender in
                            Text(gender.rawValue).tag(gender)
                                .primaryPickerStyle(width: 120, height: 25)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 120, height: 100)
                }
                TextField("Straße & Hausnummer eingeben:", text: $profileVM.locationStreetInput)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                TextField("PLZ & Ort eingeben:", text: $profileVM.locationCityInput)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                TextField("Email:", text: $profileVM.contactEmailInput)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                TextField("Telefonnummer:", text: $profileVM.contactPhoneInput)
                    .frame(height: 30)
                    .padding(8)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 24)
                HStack{
                    Button("Speichern"){
                        if !profileVM.locationStreetInput.isEmpty || !profileVM.locationCityInput.isEmpty {
                                profileVM.setLocation()
                            }
                            
                            if !profileVM.contactEmailInput.isEmpty || !profileVM.contactPhoneInput.isEmpty {
                                profileVM.setContactInfo()
                            }
                            
                            let updates = profileVM.getUpdatedFields()
                            if !updates.isEmpty {
                                profileVM.editProfile(updates: updates)
                            } else {
                                print("No Changes")
                            }
                    }
                    .primaryButtonStyle()
                    
                }
            }
            .padding(.top, 32)
        }
        .onAppear {
            profileVM.setProfileInfos()
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileViewModel())
    
}


   

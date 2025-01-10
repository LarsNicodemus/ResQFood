//
//  ProfileOverView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI
import PhotosUI

struct ProfileOverView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var imageVM: ImageViewModel

    var body: some View {
        ScrollView {
            VStack {
                if let user = profileVM.userProfile {
                    Button{
                        
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                    PhotosPicker(
                        selection: $imageVM.selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        ProfileImageView(imageurl: user.pictureUrl)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {

                        HStack {
                            Image(systemName: "person.fill")
                            Text("Username: \(user.username)")
                                .font(.headline)
                        }

                        HStack {
                            Image(systemName: "calendar")
                            Text(user.birthDay != nil ? "Geburtstag: \(user.birthDay!.formatted(Date.FormatStyle().year().month().day().locale(Locale(identifier: "de_DE"))))" : "Geburtstag: nicht angegeben.")
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "star.fill")
                            Text(user.rating != nil ? "Bewertung: \(user.rating!)" : "Bewertung: noch keine Einträge.")
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                            Text("Gesammelte Punkte: \(user.points ?? 0)")
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text(user.gender != nil ? "Geschlecht: \(user.gender!)" : "Geschlecht: nicht angegeben.")
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "envelope")
                            Text("E-Mail: \(user.contactInfo?.email ?? "Keine E-Mail")")
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Telefonnummer: \(user.contactInfo?.number ?? "keine Telefonnummer")")
                                .font(.subheadline)
                        }

                        if let city = user.location?.city, let street = user.location?.Street, let number = user.location?.number, let zip = user.location?.zipCode {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text("Standort:")
                                        .font(.headline)
                                }
                                Text("\(street) \(number), \(zip) \(city)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color("primaryContainer")))
                    .shadow(radius: 5)
                    .applyTextColor(Color("OnPrimaryContainer"))
                }
            }
            .padding()
        }
        .customBackButton()
        .onChange(of: imageVM.selectedItem) { oldItems, newItems in
                    Task {
                        await imageVM.handleImageSelection(newItem: newItems)
                        if let _ = imageVM.selectedImage {
                            await imageVM.uploadImage()
                            profileVM.pictureUrl = imageVM.uploadedImage?.url
                            profileVM.editDonation(updates: [.pictureUrl :  profileVM.pictureUrl as Any])
                        }
                    }
                }
    }
}

#Preview {
    ProfileOverView()
        .environmentObject(ProfileViewModel())
        .environmentObject(ImageViewModel())
}

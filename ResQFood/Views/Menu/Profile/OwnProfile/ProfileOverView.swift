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
    @State var sheetPresent: Bool = false
    var body: some View {
        VStack{
            ScrollView {
                VStack {
                    if let user = profileVM.userProfile {
                        HStack{
                            Spacer()
                            Button{
                                sheetPresent = true
                            } label: {
                                Image(systemName: "pencil.circle")
                                    .resizable()
                                    .frame(width: 32,height: 32)
                                    .tint(Color("primaryAT"))
                            }
                        }.padding(.trailing)
                            
                        PhotosPicker(
                            selection: $imageVM.selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ProfileImageView(imageurl: user.pictureUrl)
                        }
                        .padding(.bottom, 32)
                        VStack(alignment: .leading, spacing: 20) {

                            HStack {
                                Image(systemName: "person.fill")
                                Text("Username: \(user.username)")
                                    .bold()
                            }

                            HStack {
                                Image(systemName: "calendar")
                                Text(user.birthDay != nil ? "Geburtstag: \(user.birthDay!.formatted(Date.FormatStyle().year().month().day().locale(Locale(identifier: "de_DE"))))" : "Geburtstag: nicht angegeben.")
                            }

                            HStack {
                                Image(systemName: "star.fill")
                                Text(user.rating != nil ? "Bewertung: \(user.rating!)" : "Bewertung: noch keine Einträge.")
                            }

                            HStack {
                                Image(systemName: "point.3.connected.trianglepath.dotted")
                                Text("Gesammelte Punkte: \(user.points ?? 0)")
                            }

                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text(user.gender != nil ? "Geschlecht: \(user.gender!)" : "Geschlecht: nicht angegeben.")
                            }

                            HStack {
                                Image(systemName: "envelope")
                                Text("E-Mail: \(user.contactInfo?.email ?? "Keine E-Mail")")
                            }

                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Telefonnummer: \(user.contactInfo?.number ?? "keine Telefonnummer")")
                            }

                            if let city = user.location?.city, let street = user.location?.street, let number = user.location?.number, let zip = user.location?.zipCode {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "house.fill")
                                        Text("Standort:")
                                    }
                                    Text("\(street) \(number), \(zip) \(city)")
                                        .padding(.leading, 32)
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
        }
        .background(Color("surface"))
        .customBackButton()
        .sheet(isPresented: $sheetPresent, content: {
            EditProfileView()
        })
        .onChange(of: imageVM.selectedItem) { oldItems, newItems in
                    Task {
                        await imageVM.handleImageSelection(newItem: newItems)
                        if let _ = imageVM.selectedImage {
                            await imageVM.uploadImage()
                            profileVM.pictureUrl = imageVM.uploadedImage?.url
                            profileVM.editProfile(updates: [.pictureUrl :  profileVM.pictureUrl as Any])
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

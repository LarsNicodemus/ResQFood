//
//  ProfileView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    var userID: String
    var fromChat: Bool
    @State var sheetPresent: Bool = false
    @State var report: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                if let user = chatVM.userProfile {
                    HStack{
                        Spacer()
                        VStack{
                            Button{
                                sheetPresent = true
                                report = true
                            } label: {
                                Image(systemName: "exclamationmark.bubble.fill")
                                    .resizable()
                                    .frame(width: 32,height: 32)
                                    .tint(Color("primaryAT"))
                            }
                            if !fromChat {
                                Button{
                                    sheetPresent = true
                                } label: {
                                    Image(systemName: "ellipsis.message")
                                        .resizable()
                                        .frame(width: 32,height: 32)
                                        .tint(Color("primaryAT"))
                                }
                            }
                        }
                    }.padding(.trailing)
                        ProfileImageView(imageurl: user.pictureUrl)
                    .padding(.bottom, 32)
                    VStack(alignment: .leading, spacing: 20) {

                        HStack {
                            Image(systemName: "person.fill")
                            Text("Username: \(user.username)")
                                .bold()
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

                        if let city = user.location?.city, let zip = user.location?.zipCode {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text("Standort:")
                                }
                                Text("\(zip) \(city)")
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
        
        .customBackButton()
        .sheet(isPresented: $sheetPresent, content: {
            if report {
                ReportSheet(sheetPresent: $sheetPresent, report: $report)
            } else {
                MessageSheet(sheetPresent: $sheetPresent)
            }
        })
        .onAppear{
            chatVM.getOtherUserByID(id: userID)
        }
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
    ProfileView(userID: "Y146c6TahWgGnDALyw7DGgHhzfZ2", fromChat: false)
        .environmentObject(ProfileViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(ChatViewModel())
}

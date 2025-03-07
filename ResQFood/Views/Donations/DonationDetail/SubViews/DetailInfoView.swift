//
//  DetailInfoView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct DetailInfoView: View {
    var donation: FoodDonation
    @Binding var locationName: String
    @Binding var showChat: Bool
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var donVM: DonationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(donation.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("primaryAT"))

                Spacer()

                VStack {
                   
                    if let currentUserID = donVM.getuserID(), currentUserID != donation.creatorID {
                        NavigationLink("Anbieter") {
                            ProfileView(
                                userID: donation.creatorID, fromChat: showChat)
                        }
                        .primaryButtonStyle()
                    }

                }
            }

            Group {
                if let donator = donation.creatorName {
                    DetailRow(icon: "person", text: "Ersteller: \(donator)", type: 1)
                }
                DetailRow(
                    icon: "clock",
                    text: "Gültig bis: \(donVM.formatDate(donation.expiringDate))", type: 1)
                DetailRow(icon: "info.circle", text: donation.description, type: 2)
                    .padding(.bottom)
                DetailRow(icon: "tag", text: "Zustand: \(donation.condition)", type: 1)
                DetailRow(
                    icon: "calendar",
                    text: "MHD bis: \(donVM.formatDate(donation.bbd))", type: 1)
                .padding(.bottom)
                DetailRow(
                    icon: "map", text: "Transfer: \(donation.preferredTransfer)"
                    , type: 1)
                DetailRow(icon: "location", text: "Ort: \(locationName)", type: 1)
                    .padding(.bottom)
                DetailRow(
                    icon: "calendar.badge.plus",
                    text: "Erstellt am: \(donVM.formatDate(donation.creationDate))"
                    , type: 3)
            }
        }
        .padding()
        .background(Color("secondaryContainer"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("primaryAT"), lineWidth: 1)
        }
        .task {
            locationName = await mapVM.getAddressFromCoordinates(
                latitude: donation.location.lat,
                longitude: donation.location.long
            )
        }
    }

}


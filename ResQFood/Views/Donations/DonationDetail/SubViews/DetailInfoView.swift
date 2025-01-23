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
    var showChat: Bool
    @EnvironmentObject var mapVM: MapViewModel
    var body: some View {
        HStack {
            VStack {
                Text(donation.title)
                    .font(.system(size: 20, weight: .bold))
            }
            Spacer()
            VStack(alignment: .trailing) {
                NavigationLink("Anbieter") {
                    ProfileView(
                        userID: donation.creatorID, fromChat: showChat)
                }
                .primaryButtonStyle()
            }
        }
        .padding(.vertical)
        Text(donation.description)
        Text("Zustand: \(donation.condition)")
        let bbd = donation.bbd.formatted(
            .dateTime
                .locale(Locale(identifier: "de-DE"))
                .day()
                .month()
                .year()
        )
        Text("MHD bis: \(bbd)")
        let date = donation.expiringDate.formatted(
            .dateTime
                .locale(Locale(identifier: "de-DE"))
                .day()
                .month()
                .year()
        )
        Text("gültig bis: \(date)")
        let cdate = donation.creationDate.formatted(
            .dateTime
                .locale(Locale(identifier: "de-DE"))
                .day()
                .month()
                .year()
        )
        Text("erstellt am: \(cdate)")
        if let donator = donation.creatorName {
            Text("Ersteller: \(donator)")
        }
        if let contactInfo = donation.contactInfo {
            if let number = contactInfo.number {
                Text("Nummer: \(number)")
            }
            if let mail = contactInfo.email {
                Text("Mail: \(mail)")
            }
        }
        Text("Wo? \(donation.preferredTransfer)")
        Text("Ort: \(locationName)")
            .task {
                locationName = await mapVM.getAddressFromCoordinates(
                    latitude: donation.location.lat,
                    longitude: donation.location.long)
            }
    }
}


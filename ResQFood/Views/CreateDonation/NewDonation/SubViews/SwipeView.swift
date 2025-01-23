//
//  SwipeView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//
import SwiftUI

struct SwipeView: View {
    let donation: FoodDonation
    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        Button {
            donVM.deleteDonation(id: donation.id!)
        } label: {
            VStack {
                Text("Löschen")
                Image(systemName: "trash")
            }
            .tint(Color("error"))
        }
        
        Button {
            donVM.handleReservedAction(donation: donation)
        } label: {
            Label("Reserviert", systemImage: "bookmark.fill")
        }
        .tint(Color("primaryAT"))
        
        Button {
            Task {
                await donVM.handlePickedUpAction(donation: donation)
                do {
                    let userID = try await donVM.getUserIdByDonationID(donation.id!)
                    donVM.setUserPoints(otherUserID: userID)
                    let weightInGrams = donVM.checkAndConvertWeightToGrams(donation: donation)
                    donVM.setFoodWasteSaved(otherUserID: userID, foodWasteGramm: weightInGrams)
                    withAnimation {
                        donVM.showToast = true
                    }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 2
                    ) {
                        withAnimation {
                            donVM.showToast = false
                        }
                    }
                } catch {
                    print("Fehler beim Abrufen des UserProfiles: \(error.localizedDescription)")
                }
            }
            

        } label: {
            Label("Vergeben", systemImage: "hand.raised.square")
        }
        .tint(Color("tertiary"))
    }
}

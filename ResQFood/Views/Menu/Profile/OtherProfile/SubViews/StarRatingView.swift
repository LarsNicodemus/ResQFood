//
//  StarRatingView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 25.01.25.
//

import SwiftUI

struct StarRatingView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    var maximumRating = 5
    var onRatingChange: ((Int) -> Void)?
    @State private var showAlertAlreadyRated = false

    var body: some View {
        HStack(spacing: 0) {

            ForEach(1...maximumRating, id: \.self) { index in
                Image(
                    systemName: index <= profileVM.rating ?? 0
                        ? "star.fill" : "star"
                )
                .foregroundColor(
                    index <= profileVM.rating ?? 0 ? .yellow : .gray
                )
                .onTapGesture {
                    if let userID = profileVM.currentUserID() {
                        if let profile = profileVM.otherUserProfile {
                            if !profile.ratedBy.contains(userID) {
                                profileVM.rating = index
                                profileVM.updateRating(rating: index)
                                onRatingChange?(index)
                            } else {
                                showAlertAlreadyRated = true
                            }
                        }
                    }
                }

            }
        }
        .alert("Bewertung ändern", isPresented: $showAlertAlreadyRated) {
            Button("Bewertung löschen", role: .destructive) {
                profileVM.removeRating()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Du hast diesen Nutzer bereits bewertet. Möchtest du deine Bewertung löschen?"
            )
        }
    }

}

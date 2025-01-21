//
//  CreateView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import PhotosUI
import SwiftUI

struct CreateView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    
    
    var filteredDonations: (active: [FoodDonation], reserved: [FoodDonation], pickedUp: [FoodDonation]) {
        guard let donations = donVM.donations else { return ([], [], []) }
        
        let active = donations.filter { donation in
            !(donation.isReserved ?? false) && !(donation.pickedUp ?? false)
        }
        
        let reserved = donations.filter { donation in
            donation.isReserved ?? false && !(donation.pickedUp ?? false)
        }
        
        let pickedUp = donations.filter { donation in
            donation.pickedUp ?? false
        }
        
        return (active, reserved, pickedUp)
    }
    
    var body: some View {
        VStack {
            if let donations = donVM.donations, !donations.isEmpty {
            List {
                    DonationSection(title: "Aktive Spenden", donations: filteredDonations.active)
                    DonationSection(title: "Reservierte Spenden", donations: filteredDonations.reserved)
                    DonationSection(title: "Abgeholte Spenden", donations: filteredDonations.pickedUp)
                }.listStyle(.plain)
            }
            else {
                EmptyListPlaceholder(
                    firstText: "keine aktiven Spenden",
                    secondText: "erstell gerne eine Spende ;)")
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity
                )
            }
            
        }
        .overlay(
            Group {
                if donVM.showToast {
                    ToastView(
                        message: "Erfolgreich abgeschlossen, Punkte gutgeschrieben! Gerettete Lebensmittel aktualisiert!")
                }
            }
        )
        .overlay {
            ZStack {
                Button {
                    donVM.isPresent = true
                } label: {
                    Image(systemName: "cross.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(8)
                }
                .padding()
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .primaryButtonStyle()
            }
        }
        .onAppear {
            donVM.setupDonationsListenerForUser()
        }
        .sheet(isPresented: $donVM.isPresent) {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    InputElementsView(proxy: proxy)
                        .padding()
                }
            }
            
            .foregroundStyle(Color("primaryAT"))
        }

    }
}

#Preview {
    CreateView()
        .environmentObject(DonationViewModel())
        .environmentObject(ImageViewModel())
}



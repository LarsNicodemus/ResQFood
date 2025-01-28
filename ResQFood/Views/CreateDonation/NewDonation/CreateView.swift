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
    
    var body: some View {
        VStack {
            if let donations = donVM.donations, !donations.isEmpty {
                    List {
                        DonationSection(title: "Aktive Spenden", donations: donVM.filteredDonations.active)
                        DonationSection(title: "Reservierte Spenden", donations: donVM.filteredDonations.reserved)
                        DonationSection(title: "Abgeholte Spenden", donations: donVM.filteredDonations.pickedUp)
                }
                    .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
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
        .padding()
        .background(Color("surface"))
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
                        .frame(width: 32, height: 32)
                        .padding(4)
                }
                .padding()
                .background(Color("primaryAT"))
                .foregroundColor(Color("onPrimary"))
                .clipShape(Circle())
                .padding()
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
            }
        }
        .onAppear {
            donVM.setupDonationsListenerForUser()
        }
        .sheet(isPresented: $donVM.isPresent) {
            
            VStack{
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        InputElementsView(proxy: proxy)
                    }
                }
            }
            .onAppear{
                donVM.resetDonationFields()
            }
            .background(Color("surface"))
            .foregroundStyle(Color("primaryAT"))
        }

    }
}

#Preview {
    CreateView()
        .environmentObject(DonationViewModel())
        .environmentObject(ImageViewModel())
}

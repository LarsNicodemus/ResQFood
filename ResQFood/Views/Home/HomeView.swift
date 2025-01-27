//
//  HomeView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var homeVM: HomeViewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath
    @State var showChat: Bool = true
    var body: some View {
        VStack {
            ZStack {
                Text("ResQFood")
                    .font(Fonts.title5)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .frame(width: 240, alignment: .center)
                    .foregroundStyle(Color("primaryAT"))
                Image("Strich")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, alignment: .leading)
                    .offset(y: 26)
            }

            ScrollView {
                FoodWasteView()
                    .frame(maxWidth: .infinity, maxHeight: 360)

                VStack {
                    if authVM.userNotAnonym {
                        GreetingView(homeVM: homeVM)
                        if let foodWasteSaved = homeVM.foodWasteforID {
                            if foodWasteSaved < 1000 {
                                Text(
                                    "so viel Lebensmittelverschwendung konntest du bereits verhindern: \(String(format: "%.2f", foodWasteSaved)) g."
                                )
                            } else {
                                Text(
                                    "so viel Lebensmittelverschwendung konntest du bereits verhindern: \(String(format: "%.2f", foodWasteSaved / 1000)) Kg."
                                )
                            }
                        }
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 32)

                if let totalFoodWasteSaved = homeVM.totalFoodWaste {
                    Text(
                        "so viel Lebensmittelverschwendung konnten wir zusammen bereits verhindern: \(String(format: "%.2f", (totalFoodWasteSaved / 2)/1000)) Kg."
                    )

                }
                LinkView()
                if let donations = homeVM.reservedDonations, !donations.isEmpty
                {
                    Text("Für dich reservierte Spenden: ")
                    ForEach(donations, id: \.id) { donation in
                        NavigationLink {
                            DonationDetailView(
                                donation: donation, showChat: $showChat)
                        } label: {
                            HomeDonationListItem(donation: donation)
                                .padding(.horizontal)
                        }
                    }

                }
            }
            .scrollIndicators(.hidden)

        }
        .padding()
        .background(Color("surface"))
        .onAppear {
            homeVM.setupDonationsListener()
        }
        .onChange(of: profileVM.userProfile?.username) { oldValue, newValue in
            print(
                "Username changed from \(oldValue ?? "nil") to \(newValue ?? "nil")"
            )
            homeVM.greeting = homeVM.getTimeBasedGreeting(name: newValue)
        }
        .task {
            profileVM.setupProfileListener()

            homeVM.greeting = homeVM.getTimeBasedGreeting(
                name: profileVM.userProfile?.username)
        }
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())
}

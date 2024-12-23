//
//  AppNavigation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    //    @State private var selectedTab = 0
    //    @State var activeTab: TabModel = .home
    //
    //    init() {
    //        UITabBar.appearance().isHidden = true
    //    }
    @State var showUser = false
    var body: some View {
        if authVM.userNotAnonym {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()

                }
                
                    Tab("Donation", systemImage: "document.badge.plus") {
                        CreateView()
                    }
                
                Tab("Donations", systemImage: "list.star") {
//                    DonationsView()
                    GroceryAZView()
                }
                Tab("Menü", systemImage: "wrench") {
                    MenuView()
                }

            }
        } else {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()

                }
                
                Tab("Donations", systemImage: "list.star") {
                    DonationsView()
                }
                Tab("Menü", systemImage: "wrench") {
                    MenuView()
                }

            }
        }
        //        ZStack{
        //            VStack{
        //                TabView(selection: $activeTab) {
        //                    ForEach(TabModel.allCases, id: \.rawValue) { tab in
        //                        HStack{
        //                            tab.navigateTo
        //                        }.tag(tab)
        //                    }
        //                }
        //            }
        //            VStack {
        //                Spacer()
        //                TabBarView(activeTab: $activeTab)
        //            }
        //        }
        //        .toolbar(.hidden)
        //        ZStack(alignment: .bottom) {
        //                    TabView(selection: $selectedTab) {
        //                        HomeView()
        //                            .tag(0)
        //
        //                        CreateView()
        //                            .tag(1)
        //
        //                        DonationsView()
        //                            .tag(2)
        //                    }
        //
        //            CustomAnimatedTabBar(selectedTab: $selectedTab)
        //                        .padding(.horizontal)
        //                        .padding(.bottom)
        //                }
    }
}

#Preview {
    AppNavigation()
        .environmentObject(AuthViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(ProfileViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(LocationViewModel())

}

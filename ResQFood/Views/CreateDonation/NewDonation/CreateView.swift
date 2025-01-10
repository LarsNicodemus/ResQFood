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
    @EnvironmentObject var locVM: LocationViewModel
    @EnvironmentObject var imageVM: ImageViewModel

    var body: some View {
        VStack{
            
            ScrollView {
                

                if let donations = donVM.donations {
                    ForEach(donations, id: \.id) { donation in
                        CreateDonationListItem(donation: donation)
                    }
                } else {
                    EmptyListPlaceholder(firstText: "keine aktiven Spenden", secondText: "erstell gerne eine Spende ;)")
                }
               
            }
            
        }
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
            .overlay(
                Group {
                    if donVM.showToast {
                        ToastView(
                            message: donVM.uploadSuccessMessage
                                ?? "Etwas ist schief gelaufen!")
                    }
                }
            )
            .foregroundStyle(Color("primaryAT"))
        }

    }
}

#Preview {
    CreateView()
        .environmentObject(DonationViewModel())
        .environmentObject(LocationViewModel())
        .environmentObject(ImageViewModel())
}

//@ObservedObject var mapVM: MapViewModel
//@EnvironmentObject var chatVM: ChatViewModel
//@EnvironmentObject var donVM: DonationViewModel
//var body: some View {
//    if !mapVM.locationsInRadius.isEmpty {
//        ScrollView{
//                let donations = mapVM.locationsInRadius
//                ForEach(donations, id: \.id) { donation in
//                    NavigationLink(destination: DonationDetailView(donation: donation)) {
//                        DonationListItem(donation: donation)
//                    }
//                }
//            }
//        .scrollIndicators(.hidden)
//    } else {
//        EmptyListPlaceholder()
//    }
//
//}
//}

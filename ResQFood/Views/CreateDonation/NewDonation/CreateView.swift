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

#Preview {
    CreateView()
        .environmentObject(DonationViewModel())
        .environmentObject(LocationViewModel())
        .environmentObject(ImageViewModel())
}

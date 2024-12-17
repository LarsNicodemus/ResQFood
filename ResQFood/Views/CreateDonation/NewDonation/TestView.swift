//
//  TestView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import SwiftUI

struct TestView: View {
    @StateObject var locVM: LocationViewModel = LocationViewModel()
    @StateObject var donVM: DonationViewModel = DonationViewModel()
    var body: some View {
        VStack{
            TextField("Adresse:", text: $locVM.address)
                .frame(height: 30)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .onChange(of: locVM.address) { old, new in
                locVM.fetchCoordinates()
                if let lat = locVM.geoCodingM.latitude,
                   let long = locVM.geoCodingM.longitude {
                    donVM.location.lat = lat
                    donVM.location.long = long
                    print(String(lat))
                    print(String(long))
            }
        }
    }
}

#Preview {
    TestView()
}

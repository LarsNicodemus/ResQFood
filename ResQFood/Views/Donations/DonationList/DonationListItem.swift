//
//  DonationListItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 19.12.24.
//

import SwiftUI

struct DonationListItem: View {
    var donation: FoodDonation
    var geoManager: GeocodingManager = GeocodingManager.shared
    @State private var locationName: String = "Wird geladen..."
    var body: some View {
        HStack{
            VStack(alignment: . leading){
                HStack{
                    Text(donation.title)
                        .font(.system(size: 18,weight: .bold))
                    Spacer()
                    Text("Zustand: \(donation.condition)")
                        .font(.system(size: 10))
                }
                .padding(.bottom, 8)
                Text(donation.description)
                    .lineLimit(2)
                    .padding(.bottom, 8)
                if let donator =  donation.creatorName {
                    Text("Ersteller: \(donator)")
                }
                Text("Ort: \(locationName)")
                    .task {
                        locationName = await geoManager.getLocationName(latitude: donation.location.lat, longitude: donation.location.long)
                                }
                
            }
            VStack{
                if let image = donation.picturesUrl?.first
                {
                    ItemImageView(imageurl: image)
                        .padding(.bottom, 8)
                } else {
                    Image("placeholder")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                let date = donation.expiringDate.formatted(.dateTime
                    .locale(Locale(identifier: "de-DE"))
                    .day()
                    .month()
                    .year()
                )
                Text("gültig bis: \(date)")
                    
                    .font(.system(size: 10))
                    .frame(width: 100)
            }
        }
        .padding()
        .background(Color("primaryContainer"))
        .foregroundStyle(Color("OnPrimaryContainer"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

//#Preview {
//    DonationListItem(donation: FoodDonation())
//}

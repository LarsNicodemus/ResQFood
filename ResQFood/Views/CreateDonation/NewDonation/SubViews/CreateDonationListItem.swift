//
//  CreateDonationListItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 10.01.25.
//

import SwiftUI

struct CreateDonationListItem: View {
    var donation: FoodDonation
    @State private var locationName: String = "Wird geladen..."
    var body: some View {
        HStack{
            VStack(alignment: . leading){
                HStack{
                    Text(donation.title)
                        .font(.system(size: 18,weight: .bold))
                    Spacer()
                    VStack{
                        Text("Zustand: \(donation.condition)")
                            .font(.system(size: 10))
                            .padding(.bottom, 8)
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
                .padding(.bottom, 8)
                Text(donation.description)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .padding(.bottom, 8)
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
                
            }
        }
        .overlay(
            ZStack {
                if let pickedUp = donation.pickedUp, pickedUp {
                    Text("ABGEHOLT")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.gray)
                        .rotationEffect(Angle(degrees: 15))
                        .offset(x: -40)
                } else if let reserved = donation.isReserved, reserved {
                    Text("RESERVIERT")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.gray)
                        .rotationEffect(Angle(degrees: 15))
                        .offset(x: -40)
                }
            }
        )
        .padding(8)
        .background(Color("primaryContainer"))
        .foregroundStyle(Color("OnPrimaryContainer"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

#Preview {
    CreateDonationListItem(donation: MockData.foodDonationMock)
}

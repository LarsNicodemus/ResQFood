//
//  HomeDonationListItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 22.01.25.
//

import SwiftUI

struct HomeDonationListItem: View {
    var donation: FoodDonation
    var body: some View {
        VStack{
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
            
            .padding(8)
            .background(Color("primaryContainer").opacity(0.5))
            .foregroundStyle(Color("OnPrimaryContainer"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("primaryAT"),lineWidth: 1)
            }
            
        }
    }
}

#Preview {
    HomeDonationListItem(donation: MockData.foodDonationMock)
}



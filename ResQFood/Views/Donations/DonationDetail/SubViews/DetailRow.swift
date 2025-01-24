//
//  DetailRow.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//

import SwiftUI

struct DetailRow: View {
    var icon: String
    var text: String
    var type: Int
    
    var body: some View {
        switch type {
        case 1:
            HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color("primaryAT"))
                .frame(width: 25)
            Text(text)
                .foregroundColor(Color("OnSecondaryContainer"))
               
        }
        case 2:
            HStack(spacing: 10) {
                VStack{
                    Image(systemName: icon)
                        .foregroundColor(Color("primaryAT"))
                        .frame(width: 25)
                    Spacer()
                }
                Text(text)
                    .foregroundColor(Color("OnSecondaryContainer"))
                    .padding(8)
                    .background(Color("OnPrimaryContainer").opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("primaryAT"), lineWidth: 1)
                    }
            }
        case 3:
            HStack(spacing: 10) {
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(Color("primaryAT"))
                    .frame(width: 12)
                Text(text)
                    .font(.system(size: 10))
                    .foregroundColor(Color("OnSecondaryContainer"))
            }
        default:
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(Color("primaryAT"))
                    .frame(width: 25)
                Text(text)
                    .foregroundColor(Color("OnSecondaryContainer"))
            }
        }
    }
}


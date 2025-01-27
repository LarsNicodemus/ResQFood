//
//  MessageItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 06.01.25.
//

import SwiftUI

struct MessageItem: View {
    @EnvironmentObject var chatMV: ChatViewModel
    var content: String
    var fromSelf: Bool
    var timestamp: Date
    
    var body: some View {
        HStack {
            if fromSelf {
                Spacer()
            }

            VStack(alignment: .leading) {
                Text(content)
                    .foregroundStyle(Color("onPrimary"))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 8)
            }
            .frame(minWidth: 42, alignment: .leading)
            .padding(12)
            .padding(.bottom, 6)
            .overlay(content: {
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            let isToday = Calendar.current.isDateInToday(timestamp)
                            Text(isToday ? "Heute \(chatMV.formatTimestamp(timestamp))" : chatMV.formatTimestamp(timestamp))
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                                .frame(alignment: .bottomTrailing)
                        }
                    }
                }
                .padding(4)
                
            })
            .background(fromSelf ? Color("primaryAT") : Color("tertiary"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(
                maxWidth: UIScreen.main.bounds.width * 0.80, alignment: fromSelf ? .trailing : .leading
            )

            if !fromSelf {
                Spacer()
            }
        }.listRowSeparator(.hidden)
    }

}


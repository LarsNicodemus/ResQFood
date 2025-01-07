//
//  MessageItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 06.01.25.
//

import SwiftUI

struct MessageItem: View {
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
            .frame(minWidth: 80, alignment: .leading)
            .padding(12)
            .overlay(content: {
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(timestamp.formatted())
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .frame(alignment: .bottomTrailing)
                        }
                    }
                }
                .padding(8)
                .padding(.trailing, 4)
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

#Preview {
    MessageItem(
        content:
            "tsfasdgsdsdsdsd",
        fromSelf: false,
        timestamp: Date()
    )
}
